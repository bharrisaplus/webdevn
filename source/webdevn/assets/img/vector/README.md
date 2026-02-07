# Image icon
Starting with a vector we can use imagemagick to create an image set to use as the icon for the binary.

## Windows
Need an `.ico`
```
magick INPUT -define icon:auto-resize=256,128,64,48,32,16 OUTPUT.ico
```

## Mac
Need an `.icns`

## Linux
OS/Flavor dependent usually a '.svg' or '.png'
