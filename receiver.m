clear all;close all;clc
fc = 8240104;
Fs = 659200;%采样频率
L = 800000;   %采样点数
T = 1/Fs;
t = (0:L-1)*T;
n = 0:L-1;
ff = Fs*(((-L)/2):(L/2-1))/L;
%% 解调
DSB = (sin(2*pi*2000*t) + sin(2*pi*3000*t)).*cos(2*pi*fc*t);%经过接收机带通采样之后的DSB数字信号
NCOI = cos((pi/2)*n);
NCOQ = -sin((pi/2)*n);
ZBI1 = DSB.*NCOI;
ZBQ1 = DSB.*NCOQ;
figure();
subplot(221);stem(n(1:1000),ZBI1(1:1000));title('解调后ZBI时域波形');
subplot(222);stem(n(1:1000),ZBI1(1:1000));title('解调后ZBQ时域波形');
subplot(223);plot(ff,abs(fftshift((fft(ZBI1)))));title('解调后ZBI频谱');
subplot(224);plot(ff,abs(fftshift((fft(ZBQ1)))));title('解调后ZBQ频谱');
%%   五级级联的CIC
Fs = 659200;             %采样频率
M = 20;                  %抽取倍数
dd = 1;                  %差分延迟
Fp = 15*pi/1648;         %通带频率
Ast = 67.3;              %阻带衰减 13.46Q=67.3,Q=5
D1 = fdesign.decimator(M,'CIC',dd,Fp,Ast,Fs);    %详情可查阅fdesign.decimator的帮助文档
CIC = design(D1,'SystemObject',true);             %使用系统默认设计方法
ZBI2 = CIC(ZBI1');
ZBQ2 = CIC(ZBQ1');
ZBI2 = ZBI2';
ZBQ2 = ZBQ2';
Fs1 = Fs/M;
L1 = L/M;
T1 = 1/Fs1;
t1 = (0:L1-1)*T1;
ff1 = Fs1*(((-L1)/2):(L1/2-1))/L1;
figure();
subplot(221);stem(t1(1:1000),ZBI2(1:1000));title('CIC滤波后ZBI时域');
subplot(222);stem(t1(1:1000),ZBQ2(1:1000));title('CIC滤波后ZBQ时域');
subplot(223);plot(ff1,abs(fftshift((fft(ZBI2)))));title('CIC滤波ZBI频谱');
subplot(224);plot(ff1,abs(fftshift((fft(ZBQ2)))));title('CIC滤波后ZBQ频谱');
%% HB滤波器
TW = 0.63592;    %过渡带 wc=75π/412,wa=337π/412
Ast1 = 80; 
D2 = fdesign.decimator(2, 'Halfband','tw,ast',TW,Ast1);
HB = design(D2,'SystemObject', true);
ZBI3 = HB(ZBI2');
ZBQ3 = HB(ZBQ2');
ZBI3 = ZBI3';
ZBQ3 = ZBQ3';
Fs2 = Fs1/2;
L2 = L1/2;
T2 = 1/Fs2;
t2 = (0:L2-1)*T2;
ff2 = Fs2*(((-L2)/2):(L2/2-1))/L2;
figure();
subplot(221);stem(t2(1:1000),ZBI3(1:1000));title('HB滤波后ZBI时域');
subplot(222);stem(t2(1:1000),ZBQ3(1:1000));title('HB滤波后ZBQ时域');
subplot(223);plot(ff2,abs(fftshift(fft(ZBI3))));title('HB滤波后ZBI频谱');
subplot(224);plot(ff2,abs(fftshift(fft(ZBQ3))));title('HB滤波后ZBQ频谱');
%% 基带I、Q信号平方和开方算法
ZB1 = ZBI3.^2+ZBQ3.^2;   %此时采样率为Fs2=16480Hz
ZB1 = sqrt(ZB1);
Fs3 = Fs2;
L3 = L2;
T3 = 1/Fs2;
t3 = (0:L3-1)*T3;
ff3 = Fs3*(((-L3)/2):(L3/2-1))/L3;
fn = sin(2*pi*3000*t3) + sin(2*pi*2000*t3);
figure();
subplot(221);plot(t3,fn);xlim([0,0.01]);title('原始信号时域');
subplot(222);plot(t3,ZB1);xlim([0,0.01]);title('平方和开方算法所得信号时域');
subplot(223);plot(ff3,abs(fftshift(fft(fn))));title('原始信频谱');
subplot(224);plot(ff3,abs(fftshift(fft(ZB1))));title('平方和开方算法所得信号频谱');
%% 相位估计再补偿算法
Fs4 = Fs3;
L4 = L3;
T4 = 1/Fs4;
t4 = (0:L4-1)*T4;
ceita = atan(ZBQ3./ZBI3);
Zn = ZBI3+ZBQ3*i;
ejceita = cos(ceita)-sin(ceita)*i;     %ej^ceita
ZB2=Zn.*ejceita;
ff4 = Fs4*(((-L4)/2):(L4/2-1))/L4;
fn1 = sin(2*pi*3000*t4) + sin(2*pi*2000*t4);
figure();
subplot(221);plot(t4,fn1);xlim([0,0.01]);title('原始信号时域');
subplot(222);plot(t4,ZB2);xlim([0,0.01]);title('相位补偿算法所得信号时域');
subplot(223);plot(ff4,abs(fftshift(fft(fn))));title('原信号频谱');
subplot(224);plot(ff4,abs(fftshift(fft(ZB2))));title('相位补偿算法所得信号频谱');