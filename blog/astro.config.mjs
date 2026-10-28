// @ts-check
import { defineConfig } from 'astro/config';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import { visit } from 'unist-util-visit';

function rehypeLinkAttributes() {
  return (tree) => {
    visit(tree, 'element', (node) => {
      if (node.tagName !== 'a') return;

      // same-tab が指定されていれば属性を付与しない
      if (node.properties.title === 'same-tab') {
        delete node.properties.title;
        return;
      }

      node.properties.target = '_blank';
      node.properties.rel = ['noopener', 'noreferrer'];
    });
  };
}

// https://astro.build/config
export default defineConfig({
  site: "https://blog.ghz00.net",
  markdown: {
    remarkPlugins: [remarkMath],
    rehypePlugins: [
      rehypeKatex,
      rehypeLinkAttributes,
    ],
  }
});
