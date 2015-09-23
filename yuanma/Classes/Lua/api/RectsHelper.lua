
--------------------------------
-- @module RectsHelper
-- @parent_module mmo

--------------------------------
-- 
-- @function [parent=#RectsHelper] clearCache 
-- @param self
-- @param #int mapAreaRowNum
-- @param #int mapAreaColNum
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] removeRect 
-- @param self
-- @param #int nAreaIndex
-- @param #int type
-- @param #int rectIndex
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] isCollidingBottomOnBodysInArea 
-- @param self
-- @param #int nAreaIndex
-- @param #rect_table bottom
-- @param #bool bAtBottomDirection
-- @param #int bottomDirection
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] insertBodyRect 
-- @param self
-- @param #int nAreaIndex
-- @param #rect_table body
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] insertBottomRect 
-- @param self
-- @param #int nAreaIndex
-- @param #rect_table bottom
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] isCollidingBottomOnBottomsInArea 
-- @param self
-- @param #int nAreaIndex
-- @param #rect_table bottom
-- @param #bool bAtBottomDirection
-- @param #int bottomDirection
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] insertUndefRect 
-- @param self
-- @param #int nAreaIndex
-- @param #rect_table undef
        
--------------------------------
-- 
-- @function [parent=#RectsHelper] getInst 
-- @param self
-- @return RectsHelper#RectsHelper ret (return value: RectsHelper)
        
return nil
