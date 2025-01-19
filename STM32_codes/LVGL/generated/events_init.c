/*
* Copyright 2024 NXP
* NXP Confidential and Proprietary. This software is owned or controlled by NXP and may only be used strictly in
* accordance with the applicable license terms. By expressly accepting such terms or by downloading, installing,
* activating and/or otherwise using the software, you are agreeing that you have read, and that you agree to
* comply with and are bound by, such license terms.  If you do not agree to be bound by the applicable license
* terms, then you may not retain, install, activate or otherwise use the software.
*/

#include "events_init.h"
#include <stdio.h>
#include "lvgl.h"
#include "main.h"
#include "app.h"

#if LV_USE_FREEMASTER
#include "freemaster_client.h"
#endif

static void screen_ddlist_1_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
		case LV_EVENT_VALUE_CHANGED:
		{
			uint16_t id = lv_dropdown_get_selected(guider_ui.screen_ddlist_1);
			uint16_t cont = lv_dropdown_get_selected(guider_ui.screen_ddlist_mode);
			
			if(id == 1)
			{
				return_size();
				lv_obj_add_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
				lv_obj_clear_flag(guider_ui.screen_cont_part, LV_OBJ_FLAG_HIDDEN);
			}
			
			else
			{
				change_mode();
				lv_obj_add_flag(guider_ui.screen_cont_part, LV_OBJ_FLAG_HIDDEN);
				switch(cont) {
				case 0:
				{
					lv_obj_clear_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
					lv_obj_add_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
					lv_obj_add_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
					break;
				}
				case 1:
				{
					lv_obj_clear_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
					lv_obj_add_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
					lv_obj_add_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
					break;
				}
				case 2:
				{
					lv_obj_clear_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
					lv_obj_add_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
					lv_obj_add_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
					break;
				}
					default:
			break;
	  }
   }
  }
 }
}

static void screen_ddlist_mode_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_VALUE_CHANGED:
	{
		uint16_t mode = lv_dropdown_get_selected(guider_ui.screen_ddlist_1);
		uint16_t id = lv_dropdown_get_selected(guider_ui.screen_ddlist_mode);
		if(mode == 0)
		{
			switch(id) {
			case 0:
			{
				lv_obj_clear_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
				break;
			}
			case 1:
			{
				lv_obj_clear_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
				break;
			}
			case 2:
			{
				lv_obj_clear_flag(guider_ui.screen_cont_slider, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_but, LV_OBJ_FLAG_HIDDEN);
				lv_obj_add_flag(guider_ui.screen_cont_para, LV_OBJ_FLAG_HIDDEN);
				break;
			}
			default:
				break;
			}
			break;
	}
	default:
		break;
	}
 }
}

static void screen_btn_para_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_CLICKED:
	{
		app_start();
		break;
	}
	default:
		break;
	}
}

static void screen_btn_small_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_PRESSING:
	{
		pic_smaller();
		break;
	}
	default:
		break;
	}
}
static void screen_btn_large_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_PRESSING:
	{
		pic_larger();
		break;
	}
	default:
		break;
	}
}
static void screen_slider_4_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_RELEASED:
	{
		pre_change(guider_ui.screen_slider_4,guider_ui.screen_label_4);
		break;
	}
	default:
		break;
	}
}
static void screen_slider_3_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_RELEASED:
	{
		pre_change(guider_ui.screen_slider_3,guider_ui.screen_label_7);
		break;
	}
	default:
		break;
	}
}
static void screen_btn_slider_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_CLICKED:
	{
		slider_settings();
		para_config();
		break;
	}
	default:
		break;
	}
}

static void screen_slider_startx_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_RELEASED:
	{
		pre_change(guider_ui.screen_slider_startx,guider_ui.screen_label_startx);
		break;
	}
	default:
		break;
	}
}
static void screen_slider_starty_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_RELEASED:
	{
		pre_change(guider_ui.screen_slider_starty,guider_ui.screen_label_starty);
		break;
	}
	default:
		break;
	}
}
static void screen_slider_endx_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_RELEASED:
	{
		pre_change(guider_ui.screen_slider_endx,guider_ui.screen_label_endx);
		break;
	}
	default:
		break;
	}
}
static void screen_slider_endy_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_RELEASED:
	{
		pre_change(guider_ui.screen_slider_endy,guider_ui.screen_label_endy);
		break;
	}
	default:
		break;
	}
}
static void screen_btn_part_start_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_CLICKED:
	{
		change_size();
		break;
	}
	default:
		break;
	}
}
static void screen_btn_return_event_handler (lv_event_t *e)
{
	lv_event_code_t code = lv_event_get_code(e);

	switch (code) {
	case LV_EVENT_CLICKED:
	{
		return_size();
	}
	default:
		break;
	}
}
void events_init_screen(lv_ui *ui)
{
	lv_obj_add_event_cb(ui->screen_btn_para, screen_btn_para_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_ddlist_mode, screen_ddlist_mode_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_btn_small, screen_btn_small_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_btn_large, screen_btn_large_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_slider_4, screen_slider_4_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_slider_3, screen_slider_3_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_btn_slider, screen_btn_slider_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_ddlist_1, screen_ddlist_1_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_slider_startx, screen_slider_startx_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_slider_starty, screen_slider_starty_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_slider_endx, screen_slider_endx_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_slider_endy, screen_slider_endy_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_btn_part_start, screen_btn_part_start_event_handler, LV_EVENT_ALL, ui);
	lv_obj_add_event_cb(ui->screen_btn_return, screen_btn_return_event_handler, LV_EVENT_ALL, ui);
}

void events_init(lv_ui *ui)
{

}
