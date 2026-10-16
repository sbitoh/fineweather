package com.sbitoh.fineweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class WeatherWidget4x2Provider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val city = prefs.getString("flutter.widget_city", "太原") ?: "太原"
        val temp = prefs.getString("flutter.widget_temp", "13°") ?: "13°"
        val desc = prefs.getString("flutter.widget_desc", "小雨") ?: "小雨"
        val range = prefs.getString("flutter.widget_range", "11° / 15°") ?: "11° / 15°"
        val icon = prefs.getString("flutter.widget_icon", "🌦️") ?: "🌦️"

        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, appWidgetId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            try {
                val views = RemoteViews(context.packageName, R.layout.widget_4x2)
                views.setTextViewText(R.id.widget_4x2_city, city)
                views.setTextViewText(R.id.widget_4x2_temp, temp)
                views.setTextViewText(R.id.widget_4x2_desc, "$desc · $range")
                views.setTextViewText(R.id.widget_4x2_icon, icon)
                views.setOnClickPendingIntent(R.id.widget_4x2_root, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Throwable) {
                e.printStackTrace()
            }
        }
    }
}
