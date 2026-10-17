package com.sbitoh.fineweather

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class WeatherWidget4x2CleanProvider : AppWidgetProvider() {
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
        val icon = getPref("widget_icon") ?: "🌦️"
        val date = getPref("widget_date") ?: "Oct 17 Sat"

        val isEn = prefsFlutter.getString("flutter.app_lang", "en") == "en"
        val localizedCity = if (isEn) {
            if (city.contains("太原")) "Taiyuan" else city
        } else {
            if (city.equals("taiyuan", true)) "太原" else city
        }
        val localizedDate = if (isEn) {
            if (date.contains("月") || date.contains("周")) "Oct 17 Sat" else date
        } else {
            if (date.contains("Oct") || date.contains("Sat")) "10月17日 周六" else date
        }

        for (appWidgetId in appWidgetIds) {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            try {
                val views = RemoteViews(context.packageName, R.layout.widget_4x2_clean)
                views.setTextViewText(R.id.widget_4x2_clean_city, localizedCity)
                views.setTextViewText(R.id.widget_4x2_clean_temp, temp)
                views.setTextViewText(R.id.widget_4x2_clean_desc, sub)
                views.setTextViewText(R.id.widget_4x2_clean_icon, icon)
                views.setTextViewText(R.id.widget_4x2_clean_date, localizedDate)
                views.setOnClickPendingIntent(R.id.widget_4x2_clean_root, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
