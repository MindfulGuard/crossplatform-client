package process

import (
	"fmt"
	"os/exec"
	"runtime"
	"strconv"
)

type Process struct{}

func NewProcess() *Process {
	return &Process{}
}

func (p *Process) Kill(pid int64) error {
	var cmd *exec.Cmd
	if runtime.GOOS == "windows" {
		cmd = exec.Command("taskkill", "/F", "/PID", strconv.FormatInt(pid, 10))
	} else if runtime.GOOS == "linux" {
		cmd = exec.Command("kill", strconv.FormatInt(pid, 10))
	} else {
		return fmt.Errorf("unsupported operating system")
	}

	if err := cmd.Run(); err != nil {
		return err
	}

	return nil
}
