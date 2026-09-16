import starlight from "@astrojs/starlight";
import { defineConfig } from "astro/config";

export default defineConfig({
  site: "https://tagwerk.espadat.com",
  integrations: [
    starlight({
      title: "tagwerk",
      description: "Passive work-hours ledger for one Linux desktop running Hyprland, kitty and Omarchy.",
      logo: { src: "./src/assets/mark.svg", alt: "Espadat" },
      head: [{ tag: "link", attrs: { rel: "icon", href: "/favicon.ico", sizes: "16x16 32x32" } }],
      customCss: ["@espadat/docs-theme/styles/theme.css"],
      components: {
        Footer: "@espadat/docs-theme/components/footer.astro",
        ThemeProvider: "@espadat/docs-theme/components/theme-provider.astro",
        ThemeSelect: "@espadat/docs-theme/components/theme-select.astro",
      },
      social: [
        { icon: "github", label: "GitHub", href: "https://github.com/espadat-studio/tagwerk" },
      ],
      sidebar: [
        { label: "Home", link: "/" },
        {
          label: "Getting Started",
          items: [
            { slug: "getting-started/installation" },
            { slug: "getting-started/agent-hooks" },
            { slug: "getting-started/verification" },
          ],
        },
        { slug: "concepts" },
        { slug: "configuration" },
        { slug: "cli-reference" },
        { slug: "troubleshooting" },
        { slug: "migration" },
        { slug: "development" },
      ],
    }),
  ],
});
