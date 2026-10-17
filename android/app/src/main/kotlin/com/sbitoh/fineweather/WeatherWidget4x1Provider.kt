package com.sbitoh.fineweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class WeatherWidget4x1Provider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        val prefsFlutter = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val prefsHomeWidget = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        fun getPref(key: String): String? {
            return prefsHomeWidget.getString(key, null)
                ?: prefsFlutter.getString("flutter.$key", null)
                ?: prefsFlutter.getString(key, null)
        }

        val city = getPref("widget_city") ?: "Taiyuan"
        val temp = getPref("widget_temp") ?: "13°"
        val desc = getPref("widget_desc") ?: "Showers"
        val sub = getPref("widget_sub") ?: "Showers · 10° / 14°"
        val range = getPref("widget_range") ?: "10° / 14°"
        val icon = getPref("widget_icon") ?: "🌦️"

        val isEn = prefsFlutter.getString("flutter.app_lang", "en") == "en"
        val localizedCity = if (isEn) {
            if (city.contains("太原")) "Taiyuan" else city
        } else {
            if (city.equals("taiyuan", true)) "太原" else city
        }

        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context, appWidgetId, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            try {
                val views = RemoteViews(context.packageName, R.layout.widget_4x1)
                views.setTextViewText(R.id.widget_4x1_city, localizedCity)
                views.setTextViewText(R.id.widget_4x1_sub, sub)
                views.setTextViewText(R.id.widget_4x1_temp, temp)
                views.setTextViewText(R.id.widget_4x1_icon, icon)
                views.setOnClickPendingIntent(R.id.widget_4x1_root, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Throwable) {
                e.printStackTrace()
            }
        }
    }
}
