package com.a1ex3.mindfulguard.sql

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [SettingsDao::class], version = 1)
abstract class LocalDatabase : RoomDatabase() {
    abstract fun settingsDao(): SettingsDao
}