% 本脚本调用 Model0611,需要在执行前打开该文件
% 模型时间单位为小时
% 执行时间共计3000小时

%% 余氯模型参数赋值部分
kcl=[0.07;1.0;0.07;0.07]; % kcl1、kcl2、kcl3、kcl4―― 余氯在排水管网、污水处理厂、直排入湖、湖中的一级降解系数(h-1)；
tretention=[4.9;10;2.92]; %τ1、τ2、τ3―― 污水在排水管网、污水处理厂、直排入湖过程中的平均停留时间(h)；
Qcity= 0.344;  % 城市排入湖流量m3/s,总设计流量0.5m3/s,直排0.125m3/s，总数为0.625m3/s
V0=540000; % 湖泊初始容积 m3

%% 以下三个输入为时间序列；
% 第一列表示历经时间（单位：小时），第二列为对应时刻的数值

Ccl =[0,6;3000,6]; % 城市消毒后污水中余氯浓度 mg/L 
TP=[0,0.07;697,0.11;1441,0.16;2160,0.12;3000,0.12];% 总磷浓度
Qlake =[0,-Qcity+0.005;4320,-Qcity+0.005]; % 浓度蒸发/径流入湖/地下水补水/出水流量的总和(m3/s),湖泊以0.005m3/s的速率增长
 
%%  细菌模型参数赋值部分

Nmax = 10280;
r = 20;
k2 =8; 
a = 3.672;
m=2.08;

%% TP浓度
set_param('Model0611/From Workspace','VariableName','TP')

%% 余氯模型
set_param('Model0611/From Workspace1','VariableName','Ccl')
set_param('Model0611/Transport Delay','delay',num2str(tretention(1)+tretention(2)));
set_param('Model0611/Transport Delay1','delay',num2str(tretention(3)));
Coefficient = 0.8*exp(-kcl(1)*tretention(1)-kcl(2)*tretention(2));
set_param('Model0611/Gain','Gain',num2str(Coefficient)); 
Coefficient1 = 0.2*exp(-kcl(3)*tretention(3));
set_param('Model0611/Gain1','Gain',num2str(Coefficient1)); 
set_param('Model0611/From Workspace2','VariableName','Qlake');
set_param('Model0611/Constant','value',num2str(Qcity));
set_param('Model0611/Integrator','InitialCondition',num2str(V0));
set_param('Model0611/Constant1','value',num2str(kcl(4)));

%% 细菌模型
set_param('Model0611/Constant2','value',num2str(Nmax));
set_param('Model0611/Constant4','value',num2str(a));
set_param('Model0611/Constant5','value',num2str(r));
set_param('Model0611/Constant7','value',num2str(m));
set_param('Model0611/Constant8','value',num2str(k2));
set_param('Model0611/Integrator3','InitialCondition',num2str(2500));

%% 运行模型
[t,~,y] = sim('Model0611',3000); % 运行3000小时
% t为时间，y第一列为余氯，第二列为细菌数目

%% 绘制结果
fig = figure;
subplot(1,2,1)
plot(t,y(:,1),'LineWidth',2.5,'MarkerEdgeColor',[0.80,0.20,0.20])
xlabel('时间/h')
ylabel('余氯浓度 mg/L')
 set(gca, 'FontSize', 16)
subplot(1,2,2)
plot(t,y(:,2),'LineWidth',2.5,'MarkerEdgeColor',[0.30,0.75,0.93])
xlabel('时间/h')
ylabel('细菌数目 /L')
set(gca, 'FontSize', 16)
