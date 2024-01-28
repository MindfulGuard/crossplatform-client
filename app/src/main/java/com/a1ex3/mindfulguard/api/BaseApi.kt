package com.a1ex3.mindfulguard.api

interface BaseApi {
    val statusCode: Int
    fun execute(): Unit
}