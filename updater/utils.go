package main

import "os"

func getPathToScript() string {
	exePath, err := os.Executable()
	if err != nil {
		panic("Error while getting path to executable file")
	}
	return exePath
}
