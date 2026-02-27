module.exports = {
  multipass: true,
  plugins: [
    {
      name: "preset-default",
    },
    "removeDimensions", // Use viewBox instead of width/height
    "removeXMLNS", // Not needed for inline SVGs
    {
      name: "addAttributesToSVGElement",
      params: {
        attributes: [{ "aria-hidden": "true" }], // Default; override per-component
      },
    },
    "sortAttrs",
    "removeScripts", // Security: no scripts in SVGs
  ],
};
