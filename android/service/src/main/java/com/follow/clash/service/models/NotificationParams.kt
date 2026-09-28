package com.follow.clash.service.models

data class NotificationParams(
    val title: String = "po0-clash",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
    val showStopAction: Boolean = true,
)
