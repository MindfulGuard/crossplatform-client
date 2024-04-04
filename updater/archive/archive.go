package archive

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"io"
	"os"
	"path/filepath"
	"runtime"
)

type Archive struct{}

func NewArchive() *Archive {
	return &Archive{}
}

func (arch *Archive) ExtractArchive(archiveFile, dest string) error {
	os := runtime.GOOS
	switch os {
	case "windows":
		return arch.unzip(archiveFile, dest)
	case "linux":
		return arch.untarXz(archiveFile, dest)
	default:
		panic("Неизвестная операционная система:")
	}
}

func (arch *Archive) unzip(zipFile, dest string) error {
	r, err := zip.OpenReader(zipFile)
	if err != nil {
		return err
	}
	defer r.Close()

	for _, f := range r.File {
		rc, err := f.Open()
		if err != nil {
			return err
		}
		defer rc.Close()

		path := filepath.Join(dest, f.Name)

		if f.FileInfo().IsDir() {
			os.MkdirAll(path, f.Mode())
		} else {
			os.MkdirAll(filepath.Dir(path), os.ModePerm)
			f, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
			if err != nil {
				return err
			}
			defer f.Close()

			_, err = io.Copy(f, rc)
			if err != nil {
				return err
			}
		}
	}

	return nil
}

func (arch *Archive) untarXz(tarXzFile, dest string) error {
	f, err := os.Open(tarXzFile)
	if err != nil {
		return err
	}
	defer f.Close()

	gzf, err := gzip.NewReader(f)
	if err != nil {
		return err
	}
	defer gzf.Close()

	tr := tar.NewReader(gzf)

	for {
		header, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return err
		}

		target := filepath.Join(dest, header.Name)
		info := header.FileInfo()

		if info.IsDir() {
			if err := os.MkdirAll(target, os.ModePerm); err != nil {
				return err
			}
			continue
		}

		dir := filepath.Dir(target)
		if err := os.MkdirAll(dir, os.ModePerm); err != nil {
			return err
		}

		file, err := os.OpenFile(target, os.O_CREATE|os.O_RDWR, info.Mode())
		if err != nil {
			return err
		}
		defer file.Close()

		if _, err := io.Copy(file, tr); err != nil {
			return err
		}
	}

	return nil
}
