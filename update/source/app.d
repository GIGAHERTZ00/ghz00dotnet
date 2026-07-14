import vibe.vibe, std.stdio, std.digest.hmac, std.digest.sha, std.digest, std.conv, std.json, std.process, std.string:representation;

void main() {
	runApplication();
}


shared static this() {
  auto router = new URLRouter;

  router.post("/", &receiveGitHubWebhook);

  auto settings = new HTTPServerSettings;
  settings.port = environment.get("GHZ00DOTNET_UPDATE_PORT").to!ushort;
  settings.bindAddresses = ["::1", "127.0.0.1"];

  listenHTTP(settings, router);
}

void receiveGitHubWebhook(HTTPServerRequest req, HTTPServerResponse res) {
  auto webhookSecret = environment.get("GHZ00DOTNET_UPDATE_WEBHOOK_SECRET");
  string body = req.bodyReader.readAllUTF8();

  auto received = req.headers.get("X-Hub-Signature-256", "");
  auto digest = hmac!SHA256(
      body.representation,
      webhookSecret.representation
  );
  auto expected = "sha256=" ~ digest.toHexString().toLower;
  if (!constantTimeEquals(received, expected)) {
    res.statusCode = HTTPStatus.forbidden;
    res.writeBody("Invalid signature");
    return;
  }

  JSONValue payload = parseJSON(body);

  logInfo("Event: %s", req.headers.get("X-GitHub-Event", ""));
  logInfo("Repository: %s", payload["repository"]["full_name"].str);

  res.writeBody("OK");
  updater(payload);
}

bool constantTimeEquals(scope const(char)[] a, scope const(char)[] b) {
  if (a.length != b.length) {
      return false;
  }
  ubyte diff = 0;
  foreach (i; 0 .. a.length) {
    diff |= cast(ubyte)(a[i] ^ b[i]);
  }
  return diff == 0;
}

void updater(JSONValue payload){
  execute(["git","pull"]);
  logInfo("pulled!");
  struct SubSite {
    string    prefix;
    string    workDir;
    string[]  buildCommand;
    bool      changeFlg;
  }
  SubSite[] subSites = [
    SubSite("blog/","../blog", ["pnpm","build"], false),
//    SubSite("root/","../root", "pnpm build", false),
  ];
  foreach (commit; payload["commits"].array) {
    foreach (file; commit["modified"].array ~ commit["added"].array ~ commit["removed"].array) {
      foreach (ref subSite; subSites){
        if (file.str.startsWith(subSite.prefix)){
          subSite.changeFlg = true;
        }
      }
    }
  }foreach(subSite; subSites){
    if(subSite.changeFlg){
      execute(subSite.buildCommand,workDir:subSite.workDir);
    }
  }
}
