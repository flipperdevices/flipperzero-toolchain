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

	maskIndex := 0
	masks := []uint8{
		0x1,
		0x2,
		0x4,
		0x8,
		0x10,
		0x20,
		0x40,
		0x80,
	}

	var pixels []byte
	var pixel uint8
	for y := img.Bounds().Min.Y; y < img.Bounds().Max.Y; y++ {
		for x := img.Bounds().Min.X; x < img.Bounds().Max.X; x++ {
			c := img.At(x, y)
			grayColor := color.GrayModel.Convert(c).(color.Gray)
			value := grayColor.Y
			if value <= byte(float64(256)*0.5) {
				// white
				pixel |= masks[maskIndex]
			}
			maskIndex++
			if maskIndex == len(masks) {
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
