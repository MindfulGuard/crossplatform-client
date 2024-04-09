package main

import (
	"flag"
	"log"
	"mdupdater/archive"
	"mdupdater/files"
	"mdupdater/process"
	"strings"
)

func main() {
	AppFullPath := flag.String("APP_FULL_PATH", "", "application path")
	UpdatesFullPath := flag.String("UPDATES_FULL_PATH", "", "path to the directory with updated files")
	ArchiveFileFullPath := flag.String("ARCHIVE_FILE_FULL_PATH", "", "archive file path")
	MainProgramName := flag.String("MAIN_PROGRAM_NAME", "", "application name")
	FileIgnore := flag.String("FILE_IGNORE", "", "comma-delimited list of files to ignore")
	FileDeleteAfter := flag.String("FILE_DELETE_AFTER", "", "delete unnecessary files after the upgrade is complete.")
	RunAfter := flag.String("RUN_FILE_AFTER", "", "runs the file after all operations have completed.")

	flag.Parse()

	if *AppFullPath == "" || *ArchiveFileFullPath == "" || *UpdatesFullPath == "" || *MainProgramName == "" {
		log.Fatalln("You must specify values for the variables APP_FULL_PATH, UPDATES_FULL_PATH, ARCHIVE_FILE_FULL_PATH, and MAIN_PROGRAM_NAME.")
		return
	}

	var ignoreList []string
	if *FileIgnore != "" {
		ignoreList = strings.Split(*FileIgnore, ",")
	}

	var deleteAfterList []string
	if *FileDeleteAfter != "" {
		deleteAfterList = strings.Split(*FileDeleteAfter, ",")
	}

	_process_ := process.NewProcess()
	_processPId_, processPIdErr := _process_.FindPIdByName(*MainProgramName)
	if processPIdErr == nil {
		_process_.Kill(int64(_processPId_))
	}

	archive := archive.NewArchive()
	fileSync := files.NewFileSync(*UpdatesFullPath, *AppFullPath, ignoreList)

	err := archive.ExtractArchive(*ArchiveFileFullPath, *AppFullPath)
	if err != nil {
		log.Fatalf("archive extraction error: %v\n", err)
		return
	}

	err = fileSync.SyncFiles()
	if err != nil {
		log.Fatalf("file update error: %v\n", err)
		return
	}

	delErr := fileSync.DeleteAfter(*AppFullPath, deleteAfterList)
	if delErr != nil {
		log.Fatalf("error when deleting objects: %v\n", delErr)
		return
	}

	if *RunAfter != "" {
		runErr := fileSync.RunAfter(*RunAfter)
		if runErr != nil {
			log.Fatalf("file startup error: %v\n", runErr)
			return
		}
	}

	log.Println("file update was successful.")
}
