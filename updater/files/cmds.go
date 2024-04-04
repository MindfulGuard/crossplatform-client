package files

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
)

func (*FileSync) DeleteAfter(appPath string, objects []string) error {
	for _, obj := range objects {
		err := os.RemoveAll(appPath + obj)
		if err != nil {
			return err
		}
	}
	return nil
}

func (*FileSync) RunAfter(appPath string) error {
	var cmd *exec.Cmd
	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("cmd", "/c", appPath)
	case "linux":
		cmd = exec.Command("sh", "-c", appPath)
	default:
		return fmt.Errorf("unsupported operating system")
	}

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	err := cmd.Start()
	if err != nil {
		return fmt.Errorf("error starting command: %v", err)
	}

	return nil
}
