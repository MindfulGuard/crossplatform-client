package files

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

type FileSync struct {
	SourceDir        string
	TargetDir        string
	IgnoredFileNames []string
}

func NewFileSync(sourceDir, targetDir string, ignoredFileNames []string) *FileSync {
	return &FileSync{
		SourceDir:        sourceDir,
		TargetDir:        targetDir,
		IgnoredFileNames: ignoredFileNames,
	}
}

func (fs *FileSync) listFiles(dirPath string) ([]string, error) {
	var files []string

	err := filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() {
			ignored := false
			for _, ignoredFileName := range fs.IgnoredFileNames {
				if strings.Contains(info.Name(), ignoredFileName) {
					ignored = true
					break
				}
			}
			if !ignored {
				files = append(files, path)
			}
		}
		return nil
	})

	return files, err
}

func (fs *FileSync) getFileHash(filePath string) (string, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return "", err
	}
	defer file.Close()

	hash := md5.New()
	if _, err := io.Copy(hash, file); err != nil {
		return "", err
	}

	return hex.EncodeToString(hash.Sum(nil)), nil
}

func (fs *FileSync) SyncFiles() error {
	sourceFiles, err := fs.listFiles(fs.SourceDir)
	if err != nil {
		return fmt.Errorf("error listing source directory: %v", err)
	}

	targetFiles, err := fs.listFiles(fs.TargetDir)
	if err != nil {
		return fmt.Errorf("error listing target directory: %v", err)
	}

	sourceHashes := make(map[string]string)
	for _, filePath := range sourceFiles {
		relPath, err := filepath.Rel(fs.SourceDir, filePath)
		if err != nil {
			return fmt.Errorf("error getting relative path for %s: %v", filePath, err)
		}
		hash, err := fs.getFileHash(filePath)
		if err != nil {
			return fmt.Errorf("error getting hash for %s: %v", filePath, err)
		}
		sourceHashes[relPath] = hash
	}

	targetHashes := make(map[string]string)
	for _, filePath := range targetFiles {
		relPath, err := filepath.Rel(fs.TargetDir, filePath)
		if err != nil {
			return fmt.Errorf("error getting relative path for %s: %v", filePath, err)
		}
		hash, err := fs.getFileHash(filePath)
		if err != nil {
			return fmt.Errorf("error getting hash for %s: %v", filePath, err)
		}
		targetHashes[relPath] = hash
	}

	for relPath, sourceHash := range sourceHashes {
		targetHash, exists := targetHashes[relPath]
		if !exists || targetHash != sourceHash {
			sourceData, err := os.ReadFile(filepath.Join(fs.SourceDir, relPath))
			if err != nil {
				return fmt.Errorf("error reading file %s: %v", filepath.Join(fs.SourceDir, relPath), err)
			}
			targetFilePath := filepath.Join(fs.TargetDir, relPath)
			err = os.MkdirAll(filepath.Dir(targetFilePath), os.ModePerm)
			if err != nil {
				return fmt.Errorf("error creating directory: %v", err)
			}
			err = os.WriteFile(targetFilePath, sourceData, 0644)
			if err != nil {
				return fmt.Errorf("error writing file %s: %v", targetFilePath, err)
			}
		}
	}

	for relPath := range targetHashes {
		_, exists := sourceHashes[relPath]
		if !exists {
			err := os.Remove(filepath.Join(fs.TargetDir, relPath))
			if err != nil {
				return fmt.Errorf("error deleting file %s: %v", filepath.Join(fs.TargetDir, relPath), err)
			}
		}
	}

	return nil
}
