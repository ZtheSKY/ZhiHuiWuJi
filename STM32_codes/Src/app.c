#include "app.h"
#include "gui_guider.h"
#include "usart.h"
#include "fpga_spi.h"
#define AD9910_GAIN (1)

static uint16_t adc_buff_[100];

lv_ui guider_ui;

static uint32_t capture_Buf[2] = {0};   //存放计数值
static uint8_t capture_flag = 0;    //状态标志位

void clear_capture_flag()
{
	capture_flag=0;
}

void add_capture_flag()
{
	capture_flag+=1;
}

uint8_t get_capture_flag()
{
	return capture_flag;
}

void set_capture_buff1(uint32_t value_)
{
	capture_Buf[0]= value_;
}

void set_capture_buff2(uint32_t value_)
{
	capture_Buf[1]= value_;
}


uint32_t get_capture_cycle()
{
	clear_capture_flag();
	HAL_TIM_IC_Start_IT(&htim2, TIM_CHANNEL_4);
	while (get_capture_flag()!=2){delay_us(1);}
	
	
	return (capture_Buf[1]-capture_Buf[0]);
}

float32_t measure_freq()
{
	uint32_t max=0;
	uint32_t temp=0;
	for (int j=0;j<10;j++)
	{
		temp=0;
	for (int i=0;i<10;i++)
	{
		temp+=get_capture_cycle();
	}
	if (temp>max)
	{
		max=temp;
	}
	}
	float32_t freq=84.0*MHz/(max/10.0);
	freq=floorf(freq+1);
	//printf("freq:%f\n",freq);
	return freq;
}

void set_dac_ch1(uint16_t value)
{
		HAL_DAC_SetValue(&hdac, DAC_CHANNEL_1, DAC_ALIGN_12B_R, value);
		HAL_DAC_Start(&hdac,DAC_CHANNEL_1);
}

void set_dac_ch2(uint16_t value)
{
		HAL_DAC_SetValue(&hdac, DAC_CHANNEL_2, DAC_ALIGN_12B_R, value);
		HAL_DAC_Start(&hdac,DAC_CHANNEL_2);
}

uint16_t set_gain(float32_t gain)//dB -20 +20
{
	if(gain>20 ||gain<-20)
	{
		return -1;
	}
	uint16_t dac_value=(gain+20.0)*4096.0/20.0/3.3;
	set_dac_ch1(dac_value);
	return 0;
}

uint16_t set_phase(uint16_t phase)//0~2048相移
{
	phase=phase%2048;
	fpga_write_data(phase);
	return 0;
}

void init_relay()//继电器初始化
{
	__HAL_RCC_GPIOB_CLK_ENABLE();
	
	GPIO_InitTypeDef GPIO_InitStruct = {0};
	
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
	
	GPIO_InitStruct.Pin = RELAY1_PIN;
	HAL_GPIO_Init(RELAY1_PORT, &GPIO_InitStruct);

	GPIO_InitStruct.Pin = RELAY1_EN_PIN;
	HAL_GPIO_Init(RELAY1_EN_PORT, &GPIO_InitStruct);
	
	GPIO_InitStruct.Pin = RELAY2_PIN;
	HAL_GPIO_Init(RELAY2_PORT, &GPIO_InitStruct);
	
	RELAY2_CH1
	RELAY1_CH1
}

uint16_t get_adc_value_sig()
{
	HAL_ADC_Start(&hadc1);
	HAL_ADC_PollForConversion (&hadc1 ,100);
	return HAL_ADC_GetValue(&hadc1 );
}

float32_t get_adc_value(uint8_t ch)
{
	set_DMA_flag();
	if (ch==1)
	{
	HAL_ADC_Start_DMA(&hadc1, (uint32_t*)adc_buff_,100);
	}
	while(get_DMA_flag()){delay_us(1);}
	
	uint32_t temp=0;
	for(int i=0;i<100;i++)
	{
		temp+=adc_buff_[i];
	}
	return temp/100.0;
}


static uint16_t cur_width=640;
static uint16_t cur_height=480;

static uint16_t new_width;
static uint16_t new_height;


uint16_t scope_w;
uint16_t scope_h;//范围
uint16_t scope;
	
uint8_t send_width;
uint8_t send_height;//发送给FPGA的数据

uint8_t inc_width;
uint8_t inc_height;
uint16_t algo;

uint32_t pos_w;
uint32_t pos_h;


static uint16_t cw_am;//调制类型
static uint16_t amp;//增益
static uint16_t fc;//载波频率
static uint16_t ma;//调制深度

static uint16_t db;//衰减
static uint16_t delay_t;//时移
static uint16_t sita;//初相

static float32_t debug_CW_ZD_AMP=1.0;
static float32_t debug_CW_DELAY_AMP=1.0;
static float32_t debug_CW_PHASE=0.0;
static float32_t debug_AM_PHASE=0.0;
static float32_t debug_AM_AMP=1.0;
static float32_t debug_AM_MODU_AMP=1.0;

#define DELAY_CARR_CH 0
#define DELAY_MODU_CH 1
#define ORI_CARR_CH 3
#define ORI_MODU_CH 2

void get_settings()
{
	uint16_t mode = lv_roller_get_selected(guider_ui.screen_roller_para);
	
	switch (mode) {
    case 0:
        new_width = 640;
        new_height = 480;
        break;  // 结束此 case 的执行
    case 1:
        new_width = 800;
        new_height = 600;
        break;
    case 2:
        new_width = 1280;
        new_height = 720;
        break;
    case 3:
        new_width = 1920;
        new_height = 1080;
        break;
    case 4:
        new_width = 1200;
        new_height = 800;
        break;
    default:
        break;
	}
}

void slider_settings()
{
	
	pos_w = lv_slider_get_value(guider_ui.screen_slider_4);
	new_width = pos_w*2;
	
	pos_h = lv_slider_get_value(guider_ui.screen_slider_3);
	new_height = pos_h*2;	
}

uint16_t getNumber(uint16_t n) {
    // 如果n是偶数，则它本身就是最近的偶数
    if (n % 2 == 0) {
        return n;
    } else {
        // 如果n是奇数，则它下面的偶数就是n+1
        return n - 1;
    }
}

uint16_t gcd(uint16_t a, uint16_t b) {
    if (b == 0) {
        return a;
    }
    return gcd(b, a % b);
}

uint16_t get_ratio(uint16_t a, uint16_t b) {
    // 计算最大公约数
    uint16_t ratio = gcd(a, b);

    // 通过最大公约数化简比例
    int ratio_a = a / ratio;
    int ratio_b = b / ratio;

    // 判断是否符合指定的比例
    if (ratio_a == 4 && ratio_b == 3) {
        return 1;
    } else if (ratio_a == 3 && ratio_b == 2) {
        return 2;
    } else if (ratio_a == 16 && ratio_b == 9) {
        return 3;
    } else {
        return 0;
    }
}

void para_config()
{
	uint8_t step_w_total=0;
	uint8_t step_h_total=0;
	uint8_t step;
	//uint8_t cnt;

	uint8_t i;
	
	uint8_t dir_w;//
	uint8_t dir_h;
	
	uint16_t data_to_fpga;

	dir_w = cur_width < new_width?1:0;
	dir_h = cur_height < new_height?1:0;
		
	scope_w = dir_w?(new_width-cur_width):(cur_width-new_width);
	scope_h = dir_h?(new_height-cur_height):(cur_height-new_height);
	
  if(scope_w == 0)
	{
		scope = scope_h;
	}
    
  else if(scope_h == 0)
	{
		scope = scope_w;
	}
		
	else
	{
		scope = (scope_w<scope_h)?scope_w:scope_h;
	}

	step = scope >> 3;
	//cnt = step << 1;
	for (i = 0; i < step; i++)
	{
		if (i == step - 1)
		{	
			send_width = scope_w - step_w_total;
			if(dir_w)
			{
				data_to_fpga = ((128 + send_width) & 0xFF) << 8;
			}
			else
			{
				data_to_fpga = ((send_width) & 0xFF) << 8;
			}
		
			send_height = scope_h - step_h_total;
			if(dir_h)
			{
				data_to_fpga += ((128 + send_height) & 0xFF);
			}
			else
			{
				data_to_fpga += ((send_height) & 0xFF);
			}

			fpga_write_data(data_to_fpga);
		}
		else
		{
			send_width = getNumber((i + 1) * scope_w / step - step_w_total);
			step_w_total += send_width;
    		if(dir_w)
			{
				data_to_fpga = ((128 + send_width) & 0xFF) << 8;
			}
			else
			{
				data_to_fpga = ((send_width) & 0xFF) << 8;
			}

    		send_height = getNumber((i + 1) * scope_h / step - step_h_total);
			step_h_total += send_height;
			if (dir_h)
			{
				data_to_fpga += ((128 + send_height) & 0xFF);
			}
			else
			{
				data_to_fpga += ((send_height) & 0xFF);
			}
			fpga_write_data(data_to_fpga);
			delay_ms(100);
    		
		}
	}

	cur_width = new_width;
	cur_height = new_height;
}

void update_display_width()
{
    uint32_t variable = cur_width;  // 要显示的变量
    char buffer[32];     // 字符串缓冲区

    // 将变量转换为字符串
    sprintf(buffer, "%d", variable);

    // 将字符串显示到界面的label控件上
    lv_label_set_text(guider_ui.screen_label_4, buffer);
	  lv_slider_set_value(guider_ui.screen_slider_4, variable/2, LV_ANIM_OFF);
}

void update_display_height()
{
    uint32_t variable = cur_height;  // 要显示的变量
    char buffer[32];     // 字符串缓冲区

    // 将变量转换为字符串
    sprintf(buffer, "%d", variable);

    // 将字符串显示到界面的label控件上
    lv_label_set_text(guider_ui.screen_label_7, buffer);
	  lv_slider_set_value(guider_ui.screen_slider_3, variable/2, LV_ANIM_OFF);
}

void pre_change(lv_obj_t *slider,lv_obj_t *label)
{	
	  uint32_t pos = lv_slider_get_value(slider);
    char buffer[32];     // 字符串缓冲区

    // 将变量转换为字符串
    sprintf(buffer, "%d", pos*2);

    // 将字符串显示到界面的label控件上
    lv_label_set_text(label, buffer);
}

uint16_t get_max(uint16_t a,uint16_t b,uint16_t c,uint16_t d)
{
	uint16_t m1 = (a>b)?a:b;
	uint16_t m2 = (c>d)?c:d;
	uint16_t m = (m1>m2)?m1:m2;
	return m;
}

void change_size()
{
	uint16_t start_x = 2*lv_slider_get_value(guider_ui.screen_slider_startx);
	uint16_t start_y = 2*lv_slider_get_value(guider_ui.screen_slider_starty);
	uint16_t end_x = 2*lv_slider_get_value(guider_ui.screen_slider_endx);
	uint16_t end_y = 2*lv_slider_get_value(guider_ui.screen_slider_endy);
	
	volatile uint16_t scope_startx = start_x;
	volatile uint16_t scope_starty = start_y;
	
	volatile uint16_t scope_endx = 640-end_x;
	volatile uint16_t scope_endy = 480-end_y;
	
	uint8_t i,j;	
	
	volatile uint16_t scope_part = get_max(scope_startx,scope_starty,scope_endx,scope_endy);

	volatile uint16_t step = scope_part >> 3;
	volatile uint16_t startx_total=0,starty_total=0,endx_total=0,endy_total=0;//已经发送的
	
	volatile uint16_t send_startx=0,send_starty=0,send_endx=0,send_endy=0;//本次要发送的
	uint16_t data_to_fpga;
	
	//cnt = step << 1;
	for (i = 0; i < step; i++)
	{
		if (i == step - 1)
		{	
			send_startx = scope_startx - startx_total;
			send_endx = scope_endx - endx_total;
			data_to_fpga = (((send_startx<<4) + send_endx) & 0xFF) << 8;
		
			send_starty = scope_starty - starty_total;
			send_endy = scope_endy - endy_total;
			data_to_fpga += (((send_starty<<4) + send_endy) & 0xFF);

			fpga_write_data(data_to_fpga);
		}
		else
		{
			send_startx = getNumber((i + 1) * scope_startx / step - startx_total);
			startx_total += send_startx;
			
			send_endx = getNumber((i + 1) * scope_endx / step - endx_total);
			endx_total += send_endx;
			
    	data_to_fpga = (((send_startx<<4) + send_endx) & 0xFF) << 8;


    	send_starty = getNumber((i + 1) * scope_starty / step - starty_total);
			starty_total += send_starty;
			
			send_endy = getNumber((i + 1) * scope_endy / step - endy_total);
			endy_total += send_endy;
			
			data_to_fpga += (((send_starty<<4) + send_endy) & 0xFF);
			
			fpga_write_data(data_to_fpga);
			delay_ms(100);
    		
		}
	}
}

void return_size()
{
	fpga_write_data(0);
	lv_slider_set_value(guider_ui.screen_slider_startx, 0, LV_ANIM_OFF);
	lv_slider_set_value(guider_ui.screen_slider_starty, 0, LV_ANIM_OFF);
	lv_slider_set_value(guider_ui.screen_slider_endx, 320, LV_ANIM_OFF);
	lv_slider_set_value(guider_ui.screen_slider_endy, 240, LV_ANIM_OFF);
	
	pre_change(guider_ui.screen_slider_startx,guider_ui.screen_label_startx);
	pre_change(guider_ui.screen_slider_starty,guider_ui.screen_label_starty);
	pre_change(guider_ui.screen_slider_endx,guider_ui.screen_label_endx);
	pre_change(guider_ui.screen_slider_endy,guider_ui.screen_label_endy);
}

void reset_screen()
{
	fpga_write_data(65278);
}

void change_algo()
{
	fpga_write_data(1);
}


void change_mode()
{
	fpga_write_data(65535);
}

void app_start()
{
	get_settings();
	para_config();
	update_display_width();
	update_display_height();
}


void calculate_increment(uint16_t c_width, uint16_t c_height, uint8_t *i_width, uint8_t *i_height) {
    // 计算宽高的最大公约数
    uint16_t divisor = gcd(c_width, c_height);
    
    // 将宽高分别除以最大公约数，得到互质的增量
    *i_width = getNumber(c_width / divisor);
    *i_height = getNumber(c_height / divisor);
	
	  if(*i_width>100||*i_height>100)
		{
			*i_width = getNumber(c_width*10/c_height);
			*i_height = 10;
    }				
}


void pic_smaller()
{	
	uint16_t ratio;
	ratio = get_ratio(cur_width,cur_height);
	
	switch(ratio){
		case 0:
			  inc_width = 8;
		    inc_height = 4;
		    break;
		case 1:
        inc_width = 8;
        inc_height = 6;
        break;  // 结束此 case 的执行
    case 2:
        inc_width = 6;
        inc_height = 4;
        break;
    case 3:
        inc_width = 32;
        inc_height = 18;
        break;
    default:
        break;
	}
	
	//calculate_increment(cur_width, cur_height, &inc_width, &inc_height);
	
	if(cur_width-inc_width >= 320 && cur_height-inc_height >= 240)
	{
		
		new_width = cur_width - inc_width;
		new_height = cur_height - inc_height;
		
		fpga_write_data(inc_width<<8|inc_height);
	
		
		cur_width = new_width;
		cur_height = new_height;
		
		update_display_width();
	  update_display_height();
		
		delay_ms(100);
  }
}

void pic_larger()
{	
	uint16_t ratio;
	ratio = get_ratio(cur_width,cur_height);
	
	switch(ratio){
		case 0:
		    inc_width = 8;
		    inc_height = 4;
		    break;
		case 1:
        inc_width = 8;
        inc_height = 6;
        break;  // 结束此 case 的执行
    case 2:
        inc_width = 6;
        inc_height = 4;
        break;
    case 3:
        inc_width = 32;
        inc_height = 18;
        break;
    default:
        break;
	}
	//calculate_increment(cur_width, cur_height, &inc_width, &inc_height);
	
	if(cur_width+inc_width <= 2560 && cur_height+inc_height <= 1440)
	{
//		mode = lv_roller_get_selected(guider_ui.screen_ddlist_algo);
	
//		if(mode == 0)
//		{
//			send_data_to_fpga(224);//00001000
//		}	
		
//		else if(mode == 1)
//		{
//			send_data_to_fpga(225);//00000000
//		}
		
		new_width = cur_width + inc_width;
		new_height = cur_height + inc_height;
		
		fpga_write_data((128+inc_width)<<8|(128+inc_height));

		//send_data_to_fpga(128+inc_width);
		//send_data_to_fpga(128+inc_height);
		
		cur_width = new_width;
		cur_height = new_height;
		
		update_display_width();
	  update_display_height();
		
		delay_ms(100);
	}
}

void app_init()
{
	delay_init();
	
	lv_init();                          // lvgl初始化
  lv_port_disp_init();                // 显示设备初始化
  lv_port_indev_init();               // 输入设备初始化
	
	setup_ui(&guider_ui);
	events_init(&guider_ui);

	//printf("LCD ID:%x\r\n", lcddev.id);
}

void app_main_loop()
{
	lv_task_handler();
}