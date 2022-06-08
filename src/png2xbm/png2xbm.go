// Originally written by https://github.com/xyproto (https://github.com/xyproto/xbm)
// Rewritten by https://github.com/drunkbatya according ImageMagick's convert xmb:- function

package main

import (
    "os"
	"fmt"
	"image"
	"image/color"
	"image/png"
)

func printPixels(pixels []byte, width int, height int) {
	fmt.Printf("#define -_width %d\n", width)
	fmt.Printf("#define -_height %d\n", height)
	fmt.Printf("static char -_bits[] = {\n  ")
    var lineCount int = 0
    for _, imgByte := range pixels {
        fmt.Printf("0x%02X", imgByte)
        if lineCount == 11 {
            fmt.Printf(",\n  ")
            lineCount = 0
        } else {
            fmt.Printf(", ")
            lineCount++
        }
    }
	fmt.Printf("};\n")
}

// Encode will encode the given image as XBM, using a custom image name from
// the Encoder struct. The colors are first converted to grayscale, and then
// with a 50% cutoff they are converted to 1-bit colors.
func Encode(img image.Image) {
	width := img.Bounds().Dx()
	height := img.Bounds().Dy()

	real_x := img.Bounds().Max.X
	round_max_x := ((real_x + 7) / 8) * 8

	var pixels []byte
	var pixel uint8
	for y := img.Bounds().Min.Y; y < img.Bounds().Max.Y; y++ {
	    maskIndex := 0
		for x := img.Bounds().Min.X; x < round_max_x; x++ {
			var c color.Color

			if x < real_x {
				c = img.At(x, y)
			} else {
				c = color.White
			}

			_, _, _, a := c.RGBA()
			a = a>>8

			grayColor := color.GrayModel.Convert(c).(color.Gray)
			value := grayColor.Y
			if value <= byte(float64(256) * 0.5) && a >= uint32(0xFF / 2) {
				pixel |= (1 << maskIndex)
			}

			maskIndex++
			if maskIndex == 8 {
				maskIndex = 0
				pixels = append(pixels, pixel)
				pixel = 0
			}
		}
	}
    printPixels(pixels, width, height)
}

func main() {
    if len(os.Args) < 2 {
        fmt.Printf("Usage: %s [filename].png\n", os.Args[0])
        return
    }
	inputFile, err := os.Open(os.Args[1])
	image, err := png.Decode(inputFile)
    if err != nil {
        panic(err)
    }
    inputFile.Close()
    Encode(image)
}
