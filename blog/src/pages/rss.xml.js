import rss, { pagesGlobToRssItems } from '@astrojs/rss';

export async function GET(context) {
  return rss({
    title: 'GIGAHERTZ00 | blog.ghz00.net',
    description: '心に移りゆくよしなし事を、そこはかとなく書きつくろう',
    site: context.site,
    items: await pagesGlobToRssItems(import.meta.glob('./**/*.md')),
    customData: `<language>ja-jp</language>`,
  });
}