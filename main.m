clear all;close all;clc
%% f(n)和c(n)波形
fs1 = 15e4;     %采样率设为150kHz
fs2 = 15e6;     %采样率设为15MHz
fc = 824104;       %学号后六位是206026
L = 400000;        %采样点数
T1 = 1/fs1;
T2 = 1/fs2;
t1 = (0:L-1)*T1;   
t2 = (0:L-1)*T2;
ft = sin(2*pi*2000*t1)+sin(2*pi*3000*t1);  
ct=cos(2*pi*fc*t2);            
%% 第1问
F = abs(fftshift(fft(ft))); 
ff1 = fs1*(((-L)/2):(L/2-1))/L;
figure();
subplot(311);
plot(t1,ft);xlabel('t/s');title('f(t)')
xlim([0,0.003]);
subplot(312);
stem(t1,ft);   %离散波形
xlim([0,0.003]);title('f(n)')
subplot(313);
plot(ff1,F);
xlabel('f/Hz');ylabel('幅度');title('f(n)频谱')
xlim([-3200,3200]);
%% 第2问
C = abs(fftshift(fft(ct)));               
ff2 = fs2*(((-L)/2):(L/2-1))/L;
figure();
subplot(311);
plot(t2,ct);xlabel('t/s');title('c(t)')
xlim([0,1e-5]);
subplot(312);
stem(t2,ct); title('c(n)');xlim([0,1e-5]);
subplot(313);
plot(ff2,abs(C));
xlabel('f/Hz');ylabel('幅度');title('c(n)频谱')
xlim([-1e6,1e6]);
%% 第3问
% DSB调制只有I通道，Q(n)=0
t3 = t2;
Ac = 1;
fI =  sin(2*pi*2000*t3)+sin(2*pi*3000*t3);
s = fI.*cos(2*pi*fc*t3);
S = abs(fftshift(fft(s)));               
n3 = linspace(0,fs2,length(t3))-fs2/2; 
figure();
subplot(211);
plot(t3(1:20000),s(1:20000));title('DSB信号时域')
subplot(212);
plot(n3,S);
xlabel('f/Hz');ylabel('幅度');title('DSB信号频谱')
xlim([8.2e5,8.3e5]);


