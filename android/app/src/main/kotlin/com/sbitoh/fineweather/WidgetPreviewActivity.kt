package com.sbitoh.fineweather

import android.app.Activity
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView

class WidgetPreviewActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val root = FrameLayout(this).apply {
            setBackgroundColor(0xFF1E293B.toInt()) // 深色磨砂背景模拟壁纸
        }

        val inflater = LayoutInflater.from(this)

        // 渲染 4x1 小部件
        val view4x1 = inflater.inflate(R.layout.widget_4x1, root, false)
        val prefsFlutter = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val prefsHomeWidget = getSharedPreferences("HomeWidgetPreferences", MODE_PRIVATE)

        fun getPref(key: String): String? {
            return prefsHomeWidget.getString(key, null)
                ?: prefsFlutter.getString("flutter.$key", null)
                ?: prefsFlutter.getString(key, null)
        }

        val isEn = true

        val city = if (isEn) "Taiyuan" else "太原"
        val temp = "13°"
        val sub = if (isEn) "Showers · 10° / 14°" else "中度阵雨 · 10° / 14°"
        val icon = "🌦️"
        val date = if (isEn) "Oct 17 Sat" else "10月17日 周六"
        val nowLabel = if (isEn) "Now" else "现在"

        // 强行按当前全局语言转换 city、sub、date 和 nowLabel，彻底防止旧缓存滞后
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

        val localizedNow = if (isEn) "Now" else "现在"

        view4x1.findViewById<TextView>(R.id.widget_4x1_city)?.text = localizedCity
        view4x1.findViewById<TextView>(R.id.widget_4x1_sub)?.text = sub
        view4x1.findViewById<TextView>(R.id.widget_4x1_temp)?.text = temp
        view4x1.findViewById<TextView>(R.id.widget_4x1_icon)?.text = icon

        // 渲染 4x2 小部件
        val view4x2 = inflater.inflate(R.layout.widget_4x2, root, false)
        view4x2.findViewById<TextView>(R.id.widget_4x2_city)?.text = localizedCity
        view4x2.findViewById<TextView>(R.id.widget_4x2_temp)?.text = temp
        view4x2.findViewById<TextView>(R.id.widget_4x2_desc)?.text = sub
        view4x2.findViewById<TextView>(R.id.widget_4x2_icon)?.text = icon
        view4x2.findViewById<TextView>(R.id.widget_4x2_date)?.text = localizedDate
        view4x2.findViewById<TextView>(R.id.widget_4x2_now)?.text = localizedNow

        val container = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setPadding(20, 20, 20, 20)
            
            val lp4x1 = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            addView(view4x1, lp4x1)
            
            val spacer = View(this@WidgetPreviewActivity).apply {
                layoutParams = android.widget.LinearLayout.LayoutParams(
                    android.widget.LinearLayout.LayoutParams.MATCH_PARENT, 20
                )
            }
            addView(spacer)
            
            val lp4x2 = android.widget.LinearLayout.LayoutParams(
                android.widget.LinearLayout.LayoutParams.MATCH_PARENT,
                android.widget.LinearLayout.LayoutParams.WRAP_CONTENT
            )
            addView(view4x2, lp4x2)
        }

        root.addView(container)
        setContentView(root)
    }
}
