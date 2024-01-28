package com.a1ex3.mindfulguard

import android.app.Application
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.util.Log
import android.widget.TextView
import androidx.room.Room
import com.a1ex3.mindfulguard.sql.AppDatabase
import com.a1ex3.mindfulguard.sql.User
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.util.logging.Logger

class MainActivity : AppCompatActivity() {

    companion object {
        lateinit var database: AppDatabase
    }

    @OptIn(DelicateCoroutinesApi::class)
    override fun onCreate(bundle: Bundle?) {
        super.onCreate(bundle)
        setContentView(R.layout.activity_main)

        GlobalScope.launch {
            database = Room.databaseBuilder(
                applicationContext,
                AppDatabase::class.java,
                "my_database"
            ).build()
            val newUser = User(username = "JohnDoe", email = "iskitim@example.com")
            database.userDao().insertUser(newUser)
            val userList: List<User> = database.userDao().getAllUsers()

            val text: TextView = findViewById(R.id.textView)
            var result: String = ""
            for (i in userList){
                result += i.email + ", "
            }
            text.text = result
        }
    }
}