//go:build windows

package process

import "golang.org/x/sys/windows"

// Windows
func (*Process) FindPIdByName(pName string) (uint32, error) {
	const processEntrySize = 568

	h, e := windows.CreateToolhelp32Snapshot(windows.TH32CS_SNAPPROCESS, 0)
	if e != nil {
		return 0, e
	}
	p := windows.ProcessEntry32{Size: processEntrySize}
	for {
		e := windows.Process32Next(h, &p)
		if e != nil {
			return 0, e
		}
		if windows.UTF16ToString(p.ExeFile[:]) == pName {
			return p.ProcessID, nil
		}
	}
}
