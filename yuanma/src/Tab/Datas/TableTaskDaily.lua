--[[TableTaskDaily.lua
--]]

TableTaskDaily= 
{
	{ TaskID = 40001.0, TaskType = 4.0, Title = '每日必做：副本战斗', Target = '完成挑战副本1次', TaskConfigure = {kind=4.0,  copyTp=401, count=1}, Exp = 0.0, Reward = {{2.0,4800},{200004,1,4}}, RequiredLevel = 28.0, EventType = 1.0, OperateQueues = 135.0, Vitality = 3.0, },
	{ TaskID = 40002.0, TaskType = 4.0, Title = '每日必做：副本战斗', Target = '通关爬塔副本1次', TaskConfigure = {kind=1.0, copyId=501, count=1}, Exp = 0.0, Reward = {{2.0,5600},{200005,1,4}}, RequiredLevel = 37.0, EventType = 1.0, OperateQueues = 136.0, Vitality = 3.0, },
	{ TaskID = 40003.0, TaskType = 4.0, Title = '每日必做：副本战斗', Target = '通关地图boss1次', TaskConfigure = {kind=1.0, copyId=601, count=1}, Exp = 0.0, Reward = {{2.0,5600},{200005,1,4}}, RequiredLevel = 37.0, EventType = 1.0, OperateQueues = 137.0, Vitality = 3.0, },
	{ TaskID = 40004.0, TaskType = 4.0, Title = '每日必做：副本战斗', Target = '完成金钱副本1次', TaskConfigure = {kind=1.0, copyId=1, count=1}, Exp = 0.0, Reward = {{2.0,3400},{200003,1,4}}, RequiredLevel = 14.0, EventType = 1.0, OperateQueues = 138.0, Vitality = 3.0, },
	{ TaskID = 40005.0, TaskType = 4.0, Title = '每日必做：副本战斗', Target = '完成材料副本1次', TaskConfigure = {kind=1.0, copyId=101, count=1}, Exp = 0.0, Reward = {{2.0,4200},{200004,1,4}}, RequiredLevel = 23.0, EventType = 1.0, OperateQueues = 139.0, Vitality = 3.0, },
	{ TaskID = 40006.0, TaskType = 4.0, Title = '每日必做：副本战斗', Target = '完成迷宫副本1次', TaskConfigure = {kind=1.0, copyId=301, count=1}, Exp = 0.0, Reward = {{2.0,4800},{200004,1,4}}, RequiredLevel = 28.0, EventType = 1.0, OperateQueues = 140.0, Vitality = 3.0, },
	{ TaskID = 40007.0, TaskType = 4.0, Title = '每日必做：完美通关', Target = '取得1个5星关卡评价', TaskConfigure = {kind=3.0,  star=5, count=1}, Exp = 0.0, Reward = {{2.0,2600},{200003,1,4}}, RequiredLevel = 7.0, EventType = 1.0, OperateQueues = 141.0, Vitality = 3.0, },
	{ TaskID = 40008.0, TaskType = 4.0, Title = '每日必做：最高挑战', Target = '完成1次竞技场挑战', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,2600},{200003,1,4}}, RequiredLevel = 7.0, EventType = 2.0, OperateQueues = 5.0, Vitality = 3.0, },
	{ TaskID = 40009.0, TaskType = 4.0, Title = '每日必做：最高挑战', Target = '完成1次斗神殿挑战', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,5400},{200005,1,4}}, RequiredLevel = 35.0, EventType = 2.0, OperateQueues = 5.0, Vitality = 3.0, },
	{ TaskID = 40010.0, TaskType = 4.0, Title = '每日必做：全副武装', Target = '完成1次装备强化', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,3000},{200003,1,4}}, RequiredLevel = 10.0, EventType = 25.0, OperateQueues = 28.0, Vitality = 3.0, },
	{ TaskID = 40011.0, TaskType = 4.0, Title = '每日必做：宝石合成', Target = '完成1次宝石合成', TaskConfigure = {kind=1.0, count=1}, Exp = 0.0, Reward = {{2.0,4600},{200004,1,4}}, RequiredLevel = 27.0, EventType = 4.0, OperateQueues = 7.0, Vitality = 3.0, },
	{ TaskID = 40012.0, TaskType = 4.0, Title = '每日必做：装备锻造', Target = '完成1次锻造', TaskConfigure = {kind=1.0, count=1}, Exp = 0.0, Reward = {{2.0,5000},{200005,1,4}}, RequiredLevel = 30.0, EventType = 6.0, OperateQueues = 10.0, Vitality = 3.0, },
	{ TaskID = 40013.0, TaskType = 4.0, Title = '每日必做：剑灵炼化', Target = '进行1次剑魂炼化', TaskConfigure = {count=1.0} , Exp = 0.0, Reward = {{2.0,3000},{200003,1,4}}, RequiredLevel = 10.0, EventType = 9.0, OperateQueues = 15.0, Vitality = 3.0, },
	{ TaskID = 40014.0, TaskType = 4.0, Title = '每日必做：剑魂炼化', Target = '吞噬1次剑魂', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,3000},{200003,1,4}}, RequiredLevel = 10.0, EventType = 10.0, OperateQueues = 16.0, Vitality = 3.0, },
	{ TaskID = 40015.0, TaskType = 4.0, Title = '每日必做：结交好友', Target = '赠送礼物1次', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,2600},{200003,1,4}}, RequiredLevel = 7.0, EventType = 29.0, OperateQueues = 142.0, Vitality = 3.0, },
	{ TaskID = 40016.0, TaskType = 4.0, Title = '每日必做：家族贡献', Target = '家族捐献1次', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,3600},{200003,1,4}}, RequiredLevel = 16.0, EventType = 31.0, OperateQueues = 143.0, Vitality = 3.0, },
	{ TaskID = 40017.0, TaskType = 4.0, Title = '每日必做：清理任务', Target = '完成支线任务1次', TaskConfigure = {taskTp=2.0, count=1} , Exp = 0.0, Reward = {{2.0,3000},{200003,1,4}}, RequiredLevel = 10.0, EventType = 32.0, OperateQueues = 144.0, Vitality = 3.0, },
	{ TaskID = 40018.0, TaskType = 4.0, Title = '每日必做：清理任务', Target = '完成家族任务1次', TaskConfigure = {taskTp=5.0, count=1} , Exp = 0.0, Reward = {{2.0,3800},{200004,1,4}}, RequiredLevel = 18.0, EventType = 32.0, OperateQueues = 145.0, Vitality = 3.0, },
	{ TaskID = 40019.0, TaskType = 4.0, Title = '每日必做：升级境界', Target = '升级1次境界丹', TaskConfigure = {kind=1.0, count=1} , Exp = 0.0, Reward = {{2.0,2600},{200003,1,4}}, RequiredLevel = 7.0, EventType = 7.0, OperateQueues = 12.0, Vitality = 3.0, },
	{ TaskID = 40020.0, TaskType = 4.0, Title = '每日必做：战灵升级', Target = '给战灵喂食1次', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,2600},{200003,1,4}}, RequiredLevel = 7.0, EventType = 15.0, OperateQueues = 22.0, Vitality = 3.0, },
	{ TaskID = 40021.0, TaskType = 4.0, Title = '每日必做：技能升级', Target = '升级1次技能', TaskConfigure = {kind=1.0, count=1}, Exp = 0.0, Reward = {{2.0,2600},{200003,1,4}}, RequiredLevel = 7.0, EventType = 14.0, OperateQueues = 20.0, Vitality = 3.0, },
	{ TaskID = 40022.0, TaskType = 4.0, Title = '每日必做：美人镶嵌', Target = '镶嵌1个美人至组合中', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,3200},{200003,1,4}}, RequiredLevel = 13.0, EventType = 11.0, OperateQueues = 17.0, Vitality = 3.0, },
	{ TaskID = 40023.0, TaskType = 4.0, Title = '每日必做：美人亲密', Target = '与美人亲密1次', TaskConfigure = {count=1.0}, Exp = 0.0, Reward = {{2.0,3200},{200003,1,4}}, RequiredLevel = 13.0, EventType = 12.0, OperateQueues = 18.0, Vitality = 3.0, },
	{ TaskID = 40024.0, TaskType = 4.0, Title = '每日必做：好友酒坊', Target = '酒坊卖酒1次', TaskConfigure = {count=1.0} , Exp = 0.0, Reward = {{2.0,3600},{200003,1,4}}, RequiredLevel = 17.0, EventType = 33.0, OperateQueues = 146.0, Vitality = 3.0, },
	{ TaskID = 40025.0, TaskType = 4.0, Title = '每日必做：好友酒坊', Target = '光顾他人酒坊1次', TaskConfigure = {count=1.0} , Exp = 0.0, Reward = {{2.0,3600},{200003,1,4}}, RequiredLevel = 17.0, EventType = 34.0, OperateQueues = 147.0, Vitality = 3.0, },
}
