# Fianchetto colour schemes

Theme files contain the shell background roles followed by six coordinated icon shades.

## Install a scheme

Copy a bundled or downloaded scheme over `theme.json`:

```bash
cp ~/.config/quickshell/fianchetto/themes/nord-blue.json \
   ~/.config/quickshell/fianchetto/theme.json
```

Open **Fianchetto Settings → Appearance** and select **Custom file**. The file is watched, so later edits apply live.

## Create a scheme

Copy `themes/template.json`, preserve every key, change the hex values, and install it using the command above. Keep `background`, `surfaceHover`, and `border` dark enough for `text`; use related blue shades for `sky`, `mint`, `lilac`, `peach`, `rose`, and `butter`. `powerRed` is intentionally separate so the power module remains pastel red.
