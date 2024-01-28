package com.a1ex3.mindfulguard.sql

import androidx.room.Dao
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.Update

@Entity(tableName = "settings")
data class Settings(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val skey: String,
    val svalue: String
)

@Dao
interface SettingsDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSettings(user: Settings)

    @Update()
    suspend fun updateSettings(user: Settings)

    @Query("SELECT * FROM settings")
    suspend fun getAllSettings(): List<Settings>

    @Query("SELECT * FROM settings WHERE skey = :key")
    suspend fun getSearchSettings(key: String): List<Settings>
}