--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ListController.lua
-- author:    liyuhang
-- created:   2015/6/11
-- descrip:   列表控制器类
--===================================================
local ListController = class("ListController")

listLayoutType = {
    LayoutType_none = 0,
    LayoutType_horizontal = 1,
    LayoutType_vertiacl = 2,
    LayoutType_rows = 3,   
}

-- 构造函数
function ListController:ctor()
    self._strName = "ListController"        -- 控制器
    
    self._nLayoutType = listLayoutType.LayoutType_none    -- 排列方式
    
    self._pHostDelegate = nil                    -- 宿主代理
    self._pScrollItemsView = nil                 -- 滚动容器
    self._pDataSource = nil                 -- 数据源
    self._pDataSourceDelegateFunc = nil     -- 数据 元代理方法
    self._pNumOfCellDelegateFunc = nil     -- 数据 获取元素个数代理方法
    
    self._pFootOfHeightDelegateFunc = nil   -- 获取底部view高度
    self._pFootViewDelegateFunc = nil       -- 获取底部view
    self._pFootView = nil                   -- 底部view
    
    self._sCellMode = nil                   -- cell类型 “BagItemCell”
    self._pCells = {}                       -- cell集合
    self._pCellUseIndex = 0
    
    self._nCellWidth = 0                    -- cell宽
    self._nCellHeight = 0                   -- cell高
    self._nCellVertiaclDis = 0              -- 纵向间距
    self._nCellHorizontalDis = 0            -- 横向间距
    self._kCellAnchorPointType = 0          -- 默认的锚点（0.5，0.5）
end

-- 创建函数
function ListController:create(delegate,scrollView,layoutType,cellWidth,cellHeight)
    local listController = ListController.new()
    listController:dispose(delegate,scrollView,layoutType,cellWidth,cellHeight)
    return listController
end

-- 处理函数
function ListController:dispose(delegate,scrollView,layoutType,cellWidth,cellHeight)
    self._pHostDelegate = delegate
    self._pScrollItemsView = scrollView                 -- 滚动容器
    self._nLayoutType = layoutType                  
    self._sCellWidth = cellWidth
    self._sCellHeight = cellHeight
    ------------------- 结点事件------------------------
    return
end

-- 设置纵向间距
function ListController:setVertiaclDis(args)
    self._nCellVertiaclDis = args
end

-- 设置横向间距
function ListController:setHorizontalDis(args)
    self._nCellHorizontalDis = args
end

function ListController:setDataSource(dataSource)
    self._pDataSource = dataSource
    
    self._pCellUseIndex = 0
    for i=1,table.getn(self._pCells) do
    	self._pCells[i]:setVisible(false)
    end
    self._pScrollItemsView:jumpToTop()
    
    local setDataWithTypeActions = {
        [listLayoutType.LayoutType_horizontal] = function ()
        	
        end,
        [listLayoutType.LayoutType_vertiacl] = function ()
            local rowCount = self._pNumOfCellDelegateFunc()

            local nViewWidth  = self._pScrollItemsView:getContentSize().width
            local nViewHeight = self._pScrollItemsView:getContentSize().height
            local scrollViewHeight =((self._nCellVertiaclDis+self._sCellHeight)*(rowCount) > nViewHeight) and (self._nCellVertiaclDis+self._sCellHeight)*(rowCount) or nViewHeight
            self._pScrollItemsView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))

            for i = 1,rowCount do
                local cell = self._pDataSourceDelegateFunc(self._pHostDelegate,self,i)

                self._pCellUseIndex = self._pCellUseIndex + 1
                cell:setVisible(true)
                 if self._kCellAnchorPointType == 1 then 
                    cell:setPosition(nViewWidth/2+self._nCellHorizontalDis, scrollViewHeight-(self._sCellHeight+self._nCellVertiaclDis)*i)
                 else
                    cell:setPosition(nViewWidth/2+self._nCellHorizontalDis, scrollViewHeight-(self._sCellHeight+self._nCellVertiaclDis)*i + self._sCellHeight/2)
                 end
               
                if i > table.getn(self._pCells) then
                    self._pCells[i] = cell

                    cell:setAnchorPoint(cc.p(0,0))
                    self._pScrollItemsView:addChild(cell)
                end
            end
        end,
        [listLayoutType.LayoutType_rows] = function ()
            local itemCount = self._pNumOfCellDelegateFunc()
            local rowCount = math.ceil(itemCount/4)

            local nViewWidth  = self._pScrollItemsView:getContentSize().width
            local nViewHeight = self._pScrollItemsView:getContentSize().height
            
            -- 底部view获取
            local nFootViewHeight = 0
            if self._pFootOfHeightDelegateFunc ~= nil and self._pFootViewDelegateFunc ~= nil then
                nFootViewHeight = self._pFootOfHeightDelegateFunc()
            end
           
            local scrollViewHeight =((self._nCellVertiaclDis+self._sCellHeight)*(rowCount) + nFootViewHeight > nViewHeight) and (self._nCellVertiaclDis+self._sCellHeight)*(rowCount) + nFootViewHeight  or nViewHeight
            self._pScrollItemsView:setInnerContainerSize(cc.size(nViewWidth,scrollViewHeight))

            for i = 1,itemCount do
                local cell = self._pDataSourceDelegateFunc(self._pHostDelegate,self,i)
               
                local t1,t2 = math.modf((i-1)/4)
                t2 = t2*4
                
                self._pCellUseIndex = self._pCellUseIndex + 1
                cell:setVisible(true)
                cell:setPosition(t2*(self._sCellWidth+self._nCellHorizontalDis),scrollViewHeight-(self._sCellHeight+self._nCellVertiaclDis)*(t1+1))
               
                if i > table.getn(self._pCells) then
                    self._pCells[i] = cell
                    cell:setAnchorPoint(cc.p(0,0))
                    self._pScrollItemsView:addChild(cell)
                end
            end
            
            if self._pFootOfHeightDelegateFunc ~= nil and self._pFootViewDelegateFunc ~= nil and self._pFootView == nil then
                self._pFootView = self._pFootViewDelegateFunc()
                self._pScrollItemsView:addChild(self._pFootView)
            end
            
            if nFootViewHeight == 0 then
                if self._pFootView ~= nil then
            		self._pFootView:removeFromParent()
            		self._pFootView = nil
            	end
            end
        end,
    }
    
    setDataWithTypeActions[self._nLayoutType]()
end

function ListController:cellWithIndex(index)
    if self._pCells[index] ~= nil then
        return self._pCells[index]
	end
	return nil
end

function ListController:dequeueReusableCell()
    if self._pCellUseIndex < table.getn(self._pCells) then
        return self._pCells[self._pCellUseIndex+1]
    else
        return nil
	end
end

function ListController:getCellSources()
    if self._pCells ~= nil then
        return self._pCells
	end
	
	return nil
end

-- 退出函数
function ListController:onExitListController()
    print(self._strName.." onExit!")
    self._nLayoutType = listLayoutType.LayoutType_none    -- 排列方式

    self._pScrollItemsView = nil                 -- 滚动容器
    self._pDataSource = nil                 -- 数据源
    self._pDataSourceDelegateFunc = nil     -- 数据 元代理方法

    self._sCellMode = nil                   -- cell类型 “BagItemCell”
    self._sCellWidth = 0
    self._sCellHeight = 0
    self._pCells = {}                       -- cell集合
end

-- 设置单元格锚点的类型
-- 0 : 默认值Cell 子控件的锚点（0.5，0.5）不需要特殊处理
-- 1 ：Cell 子控件的锚点为（）
function ListController:setCellAnchorPointType(kCellAnchorPointType)
    self._kCellAnchorPointType = kCellAnchorPointType
end

--------------------------------------------------------------------------------------------------------------
return ListController