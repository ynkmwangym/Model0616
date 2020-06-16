function [PA,MA,PB,MB]=HSY(N,TYPE,Para,alpha)
% ������ʵ��HSY�㷨
% ���PA��MA�ǿɽ��ܲ������Ͷ�Ӧ��ģ����Ͻ��
% ���PB��MB�ǲ��ɽ��ܲ������Ͷ�Ӧ��ģ����Ͻ��
% NΪ��������
% TYPEΪ�������ֲ����ͣ�Ŀǰ������ȡֵ��̬�ֲ���NORMAL�����ȷֲ���UNIFORM,ά��number��1
% ParaΪ�����������ֲ���������̬�ֲ�Ϊ��ֵ�ͱ�׼����ȷֲ�Ϊ���޺�����
% alphaΪ����ɽ��ܺͲ��ɽ��ܲ����ֲ��Ƿ���ͬʱ������ˮƽ
% ����ǰ��Ҫ�ȳ�ʼ������ModelRunning
% ʾ����[PA,MA,PB,MB]=HSY(20000,{'UNIFORM';'UNIFORM';'UNIFORM'},[0,10;0,100;0,10],0.05);
%% �����������
PNumber=size(TYPE,1);
Parameter=zeros(N,PNumber);
for i=1:PNumber
Parameter(:,i)=Sampling(N,TYPE{i},Para(i,1),Para(i,2));    
end
%% ģ�������Ͳ�����𻮷�
ParaType = zeros(N,1); % 0�����ɽ��ܣ�1����ɽ���
Output = zeros(N,1); % ����ģ����� 
for j=1:N
  p=Parameter(j,:);
  [ParaType(j,1),Output(j,1)]=ModelRunning(p);    
end
%% ��������
Accepted = find(ParaType==1);
Unaccepted = find(ParaType==0);
PA = Parameter(Accepted,:);
MA = Output(Accepted,1);
PB = Parameter(Unaccepted,:);
MB = Output(Unaccepted,1);
disp(['�ɽ��ܲ��������ĿΪ',num2str(size(PA,1))])
disp(['���ɽ��ܲ��������ĿΪ',num2str(size(PB,1))])
%% �������� K-S
for i=1:PNumber
 H = kstest2(PA(:,i),PB(:,i),alpha);
 if H ==1
     disp(['����',num2str(i),'��',num2str(alpha),'���������£��ܾ�ԭ���裬��������ͬ�����ֲ�'])
 else
    disp(['����',num2str(i),'��',num2str(alpha),'���������£�����ԭ���裬������ͬ�����ֲ�']) 
end
end
%% ��������ֲ�/����ֲ�����
for i=1:PNumber
figure
X=Parameter(:,i);
[f1, x1] = ksdensity(X);
hold on
fill(x1,f1,'b','edgealpha',0.5,'facealpha',0.33)
[f2, x2] = ksdensity(PA(:,i));
fill(x2,f2,'r','edgealpha',0.5,'facealpha',0.33)
legend('����ֲ�','����ֲ�');
title(['����',num2str(i),'����ͺ���ֲ�']);
xlabel('����ȡֵ')
ylabel('�����ܶ�')
set(gca, 'FontSize', 20)
Name=['����',num2str(i),'.jpg'];
saveas(gcf,Name);
end

end

function Parameters = Sampling(N,type,a,b)
% �������Ӳ����ֲ��н��в�����Ŀǰ��ʵ����̬�ֲ��;��ȷֲ�������ֲ�����չ
% NΪ��������,typeΪ�ֲ����ͣ�Ŀǰ������ȡֵ��̬�ֲ���NORMAL�����ȷֲ���UNIFORM
% a,bΪ�����ֲ��ı�������̬�ֲ�Ϊ��ֵ�ͱ�׼����ȷֲ�Ϊ���޺�����
% ���ΪN��1�������
if strcmp(type,'UNIFORM')
    Parameters = rand(N,1)*(a-b)+b;
end
if strcmp(type,'NORMAL')
    Parameters = normrnd(a,b,[N,1]);
end
end

function [Behavior,Output] = ModelRunning(p)
% �������жϸ����Ĳ������Ƿ���Խ���
% pΪ�������� ά��1*n��nΪģ�Ͳ�����Ŀ��
% ���Ϊ1�����Խ��ܣ���0�������Խ��ܣ�
% ��Ҫ��д�ж�׼�򲿷�

%% ģ�����㲿��
% ��ʼģ��ΪC=C0exp(-kt)
s=[0.01,0.05,0.1,0.14,0.2];
Output1 = zeros(1,size(s,2));
for i=1:size(s,2)
Output1(1,i)=p(1)/p(2)*s(i)/(p(3)+s(i));
end
Ob = [200,1500,5000,8300,10000];
error=sum((Ob-Output1).^2./Ob./Ob);
Output = error;
%% ģ���жϲ���
if error<1
    Behavior=1;
else
    Behavior=0;
end
end
