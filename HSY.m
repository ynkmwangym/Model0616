function [PA,MA,PB,MB]=HSY(N,TYPE,Para,alpha)
% 本函数实现HSY算法
% 输出PA，MA是可接受参数集和对应的模型拟合结果
% 输出PB，MB是不可接受参数集和对应的模型拟合结果
% N为采样次数
% TYPE为各参数分布类型，目前有两个取值正态分布：NORMAL，均匀分布：UNIFORM,维度number×1
% Para为描述各参数分布的量，正态分布为均值和标准差，均匀分布为上限和下限
% alpha为检验可接受和不可接受参数分布是否相同时的显著水平
% 运行前需要先初始化函数ModelRunning
% 示例：[PA,MA,PB,MB]=HSY(20000,{'UNIFORM';'UNIFORM';'UNIFORM'},[0,10;0,100;0,10],0.05);
%% 先验参数采样
PNumber=size(TYPE,1);
Parameter=zeros(N,PNumber);
for i=1:PNumber
Parameter(:,i)=Sampling(N,TYPE{i},Para(i,1),Para(i,2));    
end
%% 模型评估和参数类别划分
ParaType = zeros(N,1); % 0代表不可接受，1代表可接受
Output = zeros(N,1); % 储存模型输出 
for j=1:N
  p=Parameter(j,:);
  [ParaType(j,1),Output(j,1)]=ModelRunning(p);    
end
%% 参数划分
Accepted = find(ParaType==1);
Unaccepted = find(ParaType==0);
PA = Parameter(Accepted,:);
MA = Output(Accepted,1);
PB = Parameter(Unaccepted,:);
MB = Output(Unaccepted,1);
disp(['可接受参数组合数目为',num2str(size(PA,1))])
disp(['不可接受参数组合数目为',num2str(size(PB,1))])
%% 参数检验 K-S
for i=1:PNumber
 H = kstest2(PA(:,i),PB(:,i),alpha);
 if H ==1
     disp(['参数',num2str(i),'在',num2str(alpha),'的显著性下，拒绝原假设，不具有相同连续分布'])
 else
    disp(['参数',num2str(i),'在',num2str(alpha),'的显著性下，接受原假设，具有相同连续分布']) 
end
end
%% 参数先验分布/后验分布绘制
for i=1:PNumber
figure
X=Parameter(:,i);
[f1, x1] = ksdensity(X);
hold on
fill(x1,f1,'b','edgealpha',0.5,'facealpha',0.33)
[f2, x2] = ksdensity(PA(:,i));
fill(x2,f2,'r','edgealpha',0.5,'facealpha',0.33)
legend('先验分布','后验分布');
title(['参数',num2str(i),'先验和后验分布']);
xlabel('参数取值')
ylabel('概率密度')
set(gca, 'FontSize', 20)
Name=['参数',num2str(i),'.jpg'];
saveas(gcf,Name);
end

end

function Parameters = Sampling(N,type,a,b)
% 本函数从参数分布中进行采样，目前仅实现正态分布和均匀分布，其余分布待拓展
% N为采样次数,type为分布类型，目前有两个取值正态分布：NORMAL，均匀分布：UNIFORM
% a,b为描述分布的变量，正态分布为均值和标准差，均匀分布为上限和下限
% 输出为N×1采样结果
if strcmp(type,'UNIFORM')
    Parameters = rand(N,1)*(a-b)+b;
end
if strcmp(type,'NORMAL')
    Parameters = normrnd(a,b,[N,1]);
end
end

function [Behavior,Output] = ModelRunning(p)
% 本函数判断给定的参数集是否可以接受
% p为参数向量 维度1*n（n为模型参数数目）
% 输出为1（可以接受）和0（不可以接受）
% 需要改写判断准则部分

%% 模型运算部分
% 初始模型为C=C0exp(-kt)
s=[0.01,0.05,0.1,0.14,0.2];
Output1 = zeros(1,size(s,2));
for i=1:size(s,2)
Output1(1,i)=p(1)/p(2)*s(i)/(p(3)+s(i));
end
Ob = [200,1500,5000,8300,10000];
error=sum((Ob-Output1).^2./Ob./Ob);
Output = error;
%% 模型判断部分
if error<1
    Behavior=1;
else
    Behavior=0;
end
end
