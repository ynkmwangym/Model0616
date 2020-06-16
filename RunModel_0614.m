% ���ű����� Model0611,��Ҫ��ִ��ǰ�򿪸��ļ�
% ģ��ʱ�䵥λΪСʱ
% ִ��ʱ�乲��3000Сʱ

%% ����ģ�Ͳ�����ֵ����
kcl=[0.07;1.0;0.07;0.07]; % kcl1��kcl2��kcl3��kcl4�D�D ��������ˮ��������ˮ������ֱ����������е�һ������ϵ��(h-1)��
tretention=[4.9;10;2.92]; %��1����2����3�D�D ��ˮ����ˮ��������ˮ������ֱ����������е�ƽ��ͣ��ʱ��(h)��
Qcity= 0.344;  % �������������m3/s,���������0.5m3/s,ֱ��0.125m3/s������Ϊ0.625m3/s
V0=540000; % ������ʼ�ݻ� m3

%% ������������Ϊʱ�����У�
% ��һ�б�ʾ����ʱ�䣨��λ��Сʱ�����ڶ���Ϊ��Ӧʱ�̵���ֵ

Ccl =[0,6;3000,6]; % ������������ˮ������Ũ�� mg/L 
TP=[0,0.07;697,0.11;1441,0.16;2160,0.12;3000,0.12];% ����Ũ��
Qlake =[0,-Qcity+0.005;4320,-Qcity+0.005]; % Ũ������/�������/����ˮ��ˮ/��ˮ�������ܺ�(m3/s),������0.005m3/s����������
 
%%  ϸ��ģ�Ͳ�����ֵ����

Nmax = 10280;
r = 20;
k2 =8; 
a = 3.672;
m=2.08;

%% TPŨ��
set_param('Model0611/From Workspace','VariableName','TP')

%% ����ģ��
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

%% ϸ��ģ��
set_param('Model0611/Constant2','value',num2str(Nmax));
set_param('Model0611/Constant4','value',num2str(a));
set_param('Model0611/Constant5','value',num2str(r));
set_param('Model0611/Constant7','value',num2str(m));
set_param('Model0611/Constant8','value',num2str(k2));
set_param('Model0611/Integrator3','InitialCondition',num2str(2500));

%% ����ģ��
[t,~,y] = sim('Model0611',3000); % ����3000Сʱ
% tΪʱ�䣬y��һ��Ϊ���ȣ��ڶ���Ϊϸ����Ŀ

%% ���ƽ��
fig = figure;
subplot(1,2,1)
plot(t,y(:,1),'LineWidth',2.5,'MarkerEdgeColor',[0.80,0.20,0.20])
xlabel('ʱ��/h')
ylabel('����Ũ�� mg/L')
 set(gca, 'FontSize', 16)
subplot(1,2,2)
plot(t,y(:,2),'LineWidth',2.5,'MarkerEdgeColor',[0.30,0.75,0.93])
xlabel('ʱ��/h')
ylabel('ϸ����Ŀ /L')
set(gca, 'FontSize', 16)
