USE [SuanMing]
GO
/****** Object:  StoredProcedure [dbo].[hAddBaZi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[hAddBaZi]
	-- Add the parameters for the stored procedure here
	@MingZhuId int,
	@GanZhiTypeId int,
	@GanId int,
	@ZhiId int,
	@GanSSId int,
	@ZhiCGanId1 int,
	@ZhiCGanId2 int,
	@ZhiCGanId3 int,
	@ZhiSSId1 int,
	@ZhiSSId2 int,
	@ZhiSSId3 int,
	@WangShuaiId int,
	@NaYinId int,
	@Year int,
	@BaZiSeq int,
	@BaZiRefId int


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into dBaZi(MingZhuId,GanZhiTypeId,GanId,ZhiId,GanSSId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,Year,BaZiSeq,BaZiRefId)
	values(@MingZhuId,@GanZhiTypeId,@GanId,@ZhiId,@GanSSId,@ZhiCGanId1,@ZhiCGanId2,@ZhiCGanId3
	,@ZhiSSId1,@ZhiSSId2,@ZhiSSId3,@WangShuaiId,@NaYinId,@Year,@BaZiSeq,@BaZiRefId)

	return SCOPE_IDENTITY();
END

GO
/****** Object:  StoredProcedure [dbo].[hAddMingZhu]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		xiaomao
-- Create date:  2016/4/30
-- Description:	添加命主信息
-- =============================================
CREATE PROCEDURE [dbo].[hAddMingZhu]
    @name nvarchar(50), 
	@xingbie nvarchar(1), 
	@iyear int,
	@imon int,
	@iday int,
	@ihour int,
	@imin int,
	@IsleapM bit,
	@ToLunar bit,
	@note nvarchar(200)
AS 
BEGIN
SET NOCOUNT ON
  create table #temptb(
    solarDt datetime,solarY int,solarM int,solarD int
	,lunarDtStr  nvarchar(50),lunarY int,lunarM  int,lunarD  int
	,isLeapY bit,isLeapM bit
	,curJQ nvarchar(4),prevJQ nvarchar(4) ,prevJQDt datetime,nextJQ nvarchar(4),nextJQDt datetime,JQMonthFromDt datetime,JQMonthToDt datetime
	,nGan nvarchar(1),nZhi nvarchar(1),yGan nvarchar(1),yZhi nvarchar(1),rGan nvarchar(1),rZhi nvarchar(1),sGan nvarchar(1),sZhi nvarchar(1) --四柱
	,consteName nvarchar(10),animal nvarchar(2),chinaConstellation nvarchar(3) --28星宿
	,SolarHoliday nvarchar(100),LunarHoliday nvarchar(100),WeekDayHoliday nvarchar(100),Week  nvarchar(3)--节日
  )
  

 insert into #temptb
 exec zConvertLunarSolar @iyear,@imon,@iday,@ihour,@imin,@IsleapM,@ToLunar

 declare @IsShun bit,@offsetDay int,@i int,@j int
 set @IsShun = 0
 select @IsShun=1 from #temptb t, zgan g where g.gan=t.nGan 
 and ((@xingbie='男' and g.YingYangId=1) or (@xingbie='女' and g.YingYangId=2))

 insert into dmingzhu(MingZhu,XingBie,GongLi,NongLi,GongLiNian,GongLiYue,GongLiRi
 ,Shi,Feng,NongLiNian,NongLiYue,NongLiRi
 ,NianGanId,NianZhiId,YueGanId,YueZhiId,RiGanId,RiZhiId,ShiGanId,ShiZhiId
 ,CurrentJieQiId,PreviousJieQiId,PreviousJieQiDate,NextJieQiId,NextJieQiDate,IsShun,Note) 
 select (case len(rtrim(ltrim(@name))) when 0 then '某人'+convert(nvarchar(8),t.solarDt,112) else @name end) as MingZhu
 ,@xingbie as XingBie,solarDt as GongLi,lunarDtStr as NongLi,solarY as GongLiNian,solarM as GongLiYue,solarD as GongLiRi
 ,@ihour as Shi,@imin as Feng,lunarY as NongLiNian,lunarM as NongLiYue,lunarD as NongLiRi
 ,ng.GanId as NianGanId,nz.ZhiId as NianZhiId,yg.GanId as YueGanId,yz.ZhiId as YueZhiId
 ,rg.GanId as RiGanId,rz.ZhiId as RiZhiId,sg.GanId as ShiGanId,sz.ZhiId as ShiZhiId
 ,cjq.JieQiId as CurrentJieQiId, pjq.JieQiId as PreviousJieQiId,prevJQDt as PreviousJieQiDate,njq.JieQiId as NextJieQiId,nextJQDt as NextJieQiDate
 ,@IsShun as IsShun,@note as Note
 from #temptb t 
 left join zGan ng on t.nGan = ng.Gan  left join zZhi nz on t.nZhi = nz.Zhi
 left join zGan yg on t.yGan = yg.Gan  left join zZhi yz on t.yZhi = yz.Zhi
 left join zGan rg on t.rGan = rg.Gan  left join zZhi rz on t.rZhi = rz.Zhi
 left join zGan sg on t.sGan = sg.Gan  left join zZhi sz on t.sZhi = sz.Zhi
 left join zJieQi cjq on t.curJQ = cjq.JieQi 
 left join zJieQi pjq on t.prevJQ = pjq.JieQi left join zJieQi njq on t.nextJQ = njq.JieQi

 declare @MingZhuId int,@GongLi datetime,@QiYunDateTime datetime,@KongWangZhiId int
 set @MingZhuId=SCOPE_IDENTITY() 
 --select @offsetDay = (case IsShun when 1 then datediff(d,GongLi,nextjieqidate) else datediff(d,previousjieqidate,GongLi) end) from dmingzhu
 --set @i = @offsetDay/3
 --set @j = @offsetDay%3
 insert into dMingZhuAdd(MingZhuId,JQMonthFromDt,JQMonthToDt)
 select @MingZhuId,JQMonthFromDt,JQMonthToDt from #temptb

 select @GongLi = GongLi,@KongWangZhiId=(RiZhiId-RiGanId+12-1)%12 from dMingZhu where MingZHuId=@MingZhuId

 --  select @QiYunDateTime=dateadd(day,minutes/12,dateadd(day,hours*5,dateadd(month,4*(days%3),dateadd(year,days/3,@GongLi))))
 select @QiYunDateTime=dateadd(month,4*(days%3),dateadd(year,days/3,@GongLi))
 from (
 select case @IsShun when 1 then datepart(day,JQMonthToDt-@GongLi) else datepart(day,@GongLi-JQMonthFromDt) end as days
,case @IsShun when 1 then datepart(hour,JQMonthToDt-@GongLi) else datepart(hour,@GongLi-JQMonthFromDt) end as hours
,case @IsShun when 1 then datepart(minute,JQMonthToDt-@GongLi) else datepart(minute,@GongLi-JQMonthFromDt) end as minutes
,* from dMingZhuAdd where MingZHuId=@MingZhuId) as mza

update dMingZhuAdd set QiYunDateTime=@QiYunDateTime,QiYunSui=datediff(year,@GongLi,@QiYunDateTime)
,KongWangZhiId1=@KongWangZhiId,KongWangZhiId2=@KongWangZhiId+1
where MingZHuId=@MingZhuId

 drop table #temptb
 --排盘
 exec hFenXiBaZi @MingZhuId
 select * from  vmingzhu order by CreateDateTime desc,mingzhu


  
END


GO
/****** Object:  StoredProcedure [dbo].[hDelMingZhu]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/5/1
-- Description:	删除命主信息
-- =============================================
CREATE PROCEDURE [dbo].[hDelMingZhu]
	-- Add the parameters for the stored procedure here
	@MingZhuId int
AS
BEGIN
	SET NOCOUNT ON;

	delete from [dbo].[dMingZhuAdd] where MingZhuId = @MingZhuId
	delete from [dbo].[dMingZhuGZGX] where MingZhuId = @MingZhuId
	delete from [dbo].[dMingZhuSS] where MingZhuId = @MingZhuId
	delete from [dbo].[dBaZi] where MingZhuId = @MingZhuId
	

	delete from [dbo].[dZiWeiXingYao]
    delete from [dbo].[dZiWei]
	delete from [dbo].dMingZhuZWAdd

    delete from [dbo].[dMingZhu] where MingZhuId = @MingZhuId

	select * from  vmingzhu order by CreateDateTime desc,mingzhu
END

GO
/****** Object:  StoredProcedure [dbo].[hFenXiBaZi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/5/1
-- Description:	八字排盘
-- =============================================
CREATE PROCEDURE [dbo].[hFenXiBaZi]
	@MingZhuId int
AS
BEGIN
	SET NOCOUNT ON;

	delete from dMingZhuSS where MingZhuId = @MingZhuId
	delete from dMingZhuGZGX where mingzhuid=@MingZhuId
	delete from dBaZi where MingZhuId = @MingZhuId
	declare @QiYunYear int,@YueGanId int,@YueZhiId int,@RiGanId int,@IsShun bit
	select @QiYunYear=datepart(yy,mza.QiYunDateTime),@YueGanId=mz.YueGanId,@YueZhiId=mz.YueZhiId,@RiGanId=mz.RiGanId,@IsShun=mz.IsShun from  [dbo].[dMingZhu] mz,[dbo].[dMingZhuAdd] mza 
	where mz.mingzhuid=mza.mingzhuid and mz.MingZhuId = @MingZhuId

	-- 年月日时柱
		insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,baziseq,bazirefid)
select t2.MingZhuId,t2.skeyid as GanZhiTypeId,null as year,t2.GanId,t2.ZhiId,t2.ZhiCGanId1,t2.ZhiCGanId2,t2.ZhiCGanId3
, case t2.skeyid when 3 then null else ss1.GXValueId end as GanSSId
,ss2.GXValueId as ZhiSSId1
,ss3.GXValueId as ZhiSSId2 ,ss4.GXValueId as ZhiSSId3 
,ssgx.GXValueId as WangShuaiId
,jz.NaYinId,null as baziseq,null as bazirefid
 from (
select t1.*,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3
from (
select mz.MingZhuId,skeyid,mz.RiGanId 
,case gzt.skeyid when 1 then nianganid when 2 then yueganid when 3 then riganid when 4 then shiganid end as GanId
,case gzt.skeyid when 1 then nianzhiid when 2 then yuezhiid when 3 then rizhiid when 4 then shizhiid end as ZhiId
  from dmingzhu mz, zsuanming gzt 
where mingzhuid=@MingZhuId and skey='bzGanZhiType' and gzt.skeyid in (1,2,3,4)) as t1
left join zZhi z on t1.ZhiId = z.Zhiid 
) as t2
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = t2.RiGanId and ss1.GanZhiId2 = t2.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = t2.RiGanId and ss2.GanZhiId2 = t2.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = t2.RiGanId and ss3.GanZhiId2 = t2.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = t2.RiGanId and ss4.GanZhiId2 = t2.ZhiCGanId3
left join zJiaZi jz on jz.jiaZiGanId = t2.GanId and jz.JiaZiZhiId = t2.ZhiId
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = t2.RiGanId and ssgx.GanZhiId2 = t2.ZhiId

	--大运
	select t2.* into #temptb from (
	select GanId=dbo.fGanOffset(@YueGanId,offset+1,@IsShun) ,ZhiId=dbo.fZhiOffset(@YueZhiId,offset+1,@IsShun),t.* from (
 select 1 as offset union select 2 as offset union select 3 as offset union select 4 as offset
 union select 5 as offset union select 6 as offset union select 7 as offset union select 8 as offset
 --union select 9 as offset union select 10 as offset 
 ) as t ) as t2

--select * from #temptb

	insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
		,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
		,WangShuaiId,NaYinId,baziseq,bazirefid)
	select @MingZhuId as MingZhuId,5 as GanZhiTypeId
	,@QiYunYear+(t.offset-1)*10 as year,t.GanId,t.ZhiId,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3
	, ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
	,ssgx.GXValueId as WangShuaiId,jz.NaYinId,t.offset,null 
	from 
	 #temptb t 
	 left join zJiaZi jz on t.GanId =jz.jiaZiGanId and t.ZhiId=jz.JiaZiZhiId
	left join zZhi z on t.ZhiId=z.ZhiId--) as t3
	left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t.GanId
	left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = z.CangGanId1
	left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = z.CangGanId2
	left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = z.CangGanId3
	left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t.ZhiId

	 
	-- 流年
	declare @SpecYear bit
	select @SpecYear = 1 from dMingZhu where MingZhuId = @MingZhuId and GongLi is not  null
	
	if(@SpecYear = 1)
    -- Insert statements for procedure here
insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
	,WangShuaiId,NaYinId,baziseq,bazirefid)
select t3.MingZhuId,7 as GanZhiTypeId,t3.Year ,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
, ss1.GXValueId  as GanSSId
,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2 ,ss4.GXValueId as ZhiSSId3 
,ssgx.GXValueId  as WangShuaiId,t3.NaYinId,t3.BaZiSeq ,bz2.BaZiId as bazirefid
 from (
 -- begin for t3
select t2.MingZhuId,t2.RiGanId,t2.CSYear + BaZiSeq as Year,BaZiSeq,t2.GanId,t2.ZhiId,t2.NaYinId
,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3 
from (
-- begin for t2
select t1.MingZhuId,t1.RiGanId,t1.CSYear,  case when jz2.JiaZiId - t1.JiaZiId1>=0 then jz2.JiaZiId - t1.JiaZiId1 else  jz2.JiaZiId - t1.JiaZiId1+120 end  as BaZiSeq, jz2.jiaZiGanId as GanId
,jz2.JiaZiZhiId as ZhiId,jz2.NaYinId from (
-- begin for t1
select mz.MingZhuId,mz.RiGanId, datepart(yy,mz.GongLi) as CSYear,jz.JiaZiId as JiaZiId1
,jz.JiaZiId + @QiYunYear- datepart(yy,mz.GongLi)+ 80 as JiaZiId2  from dmingzhu mz
left join zjiazi jz on mz.NianGanId = jz.jiaZiGanId and mz.NianZhiId = jz.JiaZiZhiId
where mingzhuid=@MingZhuId
-- end for t1
) as t1,
(select jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi
union 
select jiaziid+60 as jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi) as jz2
where jz2.JiaZiId between t1.JiaZiId1 and t1.JiaZiId2 or (t1.JiaZiId2 > 120 and jz2.JiaZiId between 1 and t1.JiaZiId2%120) 
--( t1.JiaZiId2 >= t1.JiaZiId1 and jz2.JiaZiId between t1.JiaZiId1 and t1.JiaZiId2 ) 
--or (  t1.JiaZiId2 < t1.JiaZiId1 and ((jz2.JiaZiId between t1.JiaZiId1 and 120) or (jz2.JiaZiId between 1 and t1.JiaZiId2)))
-- end for t2
 ) as t2
left join zZhi z on t2.ZhiId = z.Zhiid 
-- end for t3
) as t3
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = t3.RiGanId and ss1.GanZhiId2 = t3.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = t3.RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = t3.RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = t3.RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = t3.RiGanId and ssgx.GanZhiId2 = t3.ZhiId
left join dBaZi bz2 on bz2.MingZhuId = @MingZhuId and  bz2.GanZhiTypeId = 5 and  t3.year >= bz2.year and t3.year < bz2.Year + 10


else 

insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
	,WangShuaiId,NaYinId,baziseq,bazirefid)
select t3.MingZhuId,7 as GanZhiTypeId,null,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
, ss1.GXValueId  as GanSSId
,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2 ,ss4.GXValueId as ZhiSSId3 
,ssgx.GXValueId as WangShuaiId ,t3.NaYinId,t3.BaZiSeq ,null as bazirefid
 from (
 -- begin for t3
select t2.MingZhuId,t2.RiGanId,BaZiSeq,t2.GanId,t2.ZhiId,t2.NaYinId
,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3 
from (
-- begin for t2
select t1.MingZhuId,t1.RiGanId,jz2.JiaZiId - t1.JiaZiId1 as BaZiSeq, jz2.jiaZiGanId as GanId
,jz2.JiaZiZhiId as ZhiId,jz2.NaYinId from (
-- begin for t1
select t4.MingZhuId,t4.RiGanId,t4.JiaZiId1
, (case t4.JiaZiId2 when 0 then 120 else t4.JiaZiId2 end) as JiaZiId2 from (
-- begin for t4
select mz.MingZhuId,mz.RiGanId, jz.JiaZiId as JiaZiId1
,(jz.JiaZiId + 79)%120 as JiaZiId2  from dmingzhu mz
left join zjiazi jz on mz.NianGanId = jz.jiaZiGanId and mz.NianZhiId = jz.JiaZiZhiId
where mingzhuid=@MingZhuId
-- end for t4
) as t4
-- end for t1
) as t1,
(select jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi
union 
select jiaziid+60 as jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi) as jz2
where  ( t1.JiaZiId2 >= t1.JiaZiId1 and jz2.JiaZiId between t1.JiaZiId1 and t1.JiaZiId2 ) 
or (  t1.JiaZiId2 < t1.JiaZiId1 and ((jz2.JiaZiId between t1.JiaZiId1 and 120) or (jz2.JiaZiId between 1 and t1.JiaZiId2)))
-- end for t2
) as t2
left join zZhi z on t2.ZhiId = z.Zhiid 
-- end for t3
) as t3
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = t3.RiGanId and ss1.GanZhiId2 = t3.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = t3.RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = t3.RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = t3.RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = t3.RiGanId and ssgx.GanZhiId2 = t3.ZhiId



	--小运
	declare @JiaZiId int
select @IsShun = mz.IsShun,@RiGanId = RiGanId,@JiaZiId = jz.JiaZiId
 from dmingzhu mz
left join zjiazi jz on mz.ShiGanId = jz.jiaZiGanId and mz.ShiZhiId = jz.JiaZiZhiId
where mingzhuid=@MingZhuId 


declare  @jiazi2 table(
 JiaZiId int,
 JiaZiGanId int,
 JiaZiZhiId int,
 NaYinId int,
 year int,
 BaZiSeq int,
 BaZiRefId int 
)


if(@IsShun = 1)
    insert into @jiazi2
	 select jz2.JiaZiId, jz2.jiaZiGanId,jz2.JiaZiZhiId,jz2.NaYinId, Year,BaZiSeq,BaZiRefId from dbazi bz
    left join (select jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi
	union 
	select jiaziid+60 as jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi) as jz2 
	on jz2.JiaZiId = case (@JiaZiId + BaZiSeq ) when 120 then 120 else (@JiaZiId + BaZiSeq )%120 end
	where mingzhuid =@MingZhuId and ganzhitypeid=7 
else 
	 insert into @jiazi2
	 select jz2.JiaZiId, jz2.jiaZiGanId,jz2.JiaZiZhiId,jz2.NaYinId, Year,BaZiSeq,BaZiRefId from dbazi bz
	 left join (select jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi
	union 
	select jiaziid+60 as jiaziid,jiaziganid,jiazizhiid,NaYinId from zJiaZi) as jz2 
	on jz2.JiaZiId = case (@JiaZiId - BaZiSeq) when 0 then 120 else (@JiaZiId - BaZiSeq +120)%120 end 
	where mingzhuid =@MingZhuId and ganzhitypeid=7


insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3
	,WangShuaiId,NaYinId,baziseq,bazirefid)
select @MingZhuId as MingZhuId,6 as GanZhiTypeId,t3.year,t3.GanId,t3.ZhiId,t3.ZhiCGanId1,t3.ZhiCGanId2,t3.ZhiCGanId3
,ss1.GXValueId as GanSSId,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2,ss4.GXValueId as ZhiSSId3
,ssgx.GXValueId as WangShuaiId,t3.NaYinId,t3.BaZiSeq,t3.BaZiRefId from (
select  jz.JiaZiGanId as GanId , jz.JiaZiZhiId as ZhiId , jz.NaYinId,jz.year,jz.BaZiSeq,jz.BaZiRefId
,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  from @jiazi2 jz 
left join zZhi z on jz.JiaZiZhiId = z.Zhiid ) as t3
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = @RiGanId and ss1.GanZhiId2 = t3.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = @RiGanId and ss2.GanZhiId2 = t3.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = @RiGanId and ss3.GanZhiId2 = t3.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = @RiGanId and ss4.GanZhiId2 = t3.ZhiCGanId3
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = @RiGanId and ssgx.GanZhiId2 = t3.ZhiId
where not exists (select 1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=6) ;




	--命宫
	with mg as (
select ZhiId ,(case  (ZhiId-2+12)%12 when 0 then 12 else (ZhiId-2+12)%12 end ) as mgzhi from zZhi)

insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,baziseq,bazirefid)
select @MingZhuId as MingZhuId,8 as GanZhiTypeId,null as year,t2.GanId,t2.ZhiId,t2.ZhiCGanId1,t2.ZhiCGanId2,t2.ZhiCGanId3
, ss1.GXValueId  as GanSSId
,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2 ,ss4.GXValueId as ZhiSSId3 
,ssgx.GXValueId as WangShuaiId ,jz.NaYinId,null as baziseq,null as bazirefid
 from (
select 
-- t1.*,mg.zhiid,
ny.yueganid as ganid,ny.yuezhiid as zhiid ,t1.RiGanId
,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  
from (
select mz.NianGanId,mz.riganid, mg1.mgzhi as yuemgzhiid,mg2.mgzhi as shimgzhiid
,(26-mg1.mgzhi -mg2.mgzhi)%12 as mgzhiid from dmingzhu mz 
left join mg mg1 on mz.YueZhiId = mg1.ZhiId
left join mg mg2 on mz.shiZhiId = mg2.ZhiId
where mingzhuid=@MingZhuId) as t1
left join mg on  t1.mgzhiid=mg.mgzhi
left join vniantoyue ny on ny.yuezhiid=mg.zhiid and (ny.ganid1 = nianganid or ny.ganid2 = nianganid)
left join zZhi z on ny.yuezhiid = z.Zhiid ) as t2
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = t2.RiGanId and ss1.GanZhiId2 = t2.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = t2.RiGanId and ss2.GanZhiId2 = t2.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = t2.RiGanId and ss3.GanZhiId2 = t2.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = t2.RiGanId and ss4.GanZhiId2 = t2.ZhiCGanId3
left join zJiaZi jz on jz.jiaZiGanId = t2.GanId and jz.JiaZiZhiId = t2.ZhiId
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = t2.RiGanId and ssgx.GanZhiId2 = t2.ZhiId 
where not exists (select 1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=6)




	--胎元
	insert into dbazi(MingZhuId,GanZhiTypeId,year,GanId,ZhiId,ZhiCGanId1,ZhiCGanId2,ZhiCGanId3
	,GanSSId,ZhiSSId1,ZhiSSId2,ZhiSSId3,WangShuaiId,NaYinId,baziseq,bazirefid)
select @MingZhuId as MingZhuId,9 as GanZhiTypeId,null as year,t2.GanId,t2.ZhiId,t2.ZhiCGanId1,t2.ZhiCGanId2,t2.ZhiCGanId3
, ss1.GXValueId  as GanSSId
,ss2.GXValueId as ZhiSSId1,ss3.GXValueId as ZhiSSId2 ,ss4.GXValueId as ZhiSSId3 
,ssgx.GXValueId as WangShuaiId ,jz.NaYinId,null as baziseq,null as bazirefid
 from (
select 
 ganid, t1.zhiid ,t1.RiGanId
,z.CangGanId1 as ZhiCGanId1,z.CangGanId2 as ZhiCGanId2,z.CangGanId3 as ZhiCGanId3  
from (
select (case mz.YueGanId when 9 then 10 else (mz.YueGanId+1)%10 end ) as GanId
,(case mz.yuezhiid when 9 then 12 else (mz.yuezhiid + 3)%12 end) as ZhiId,mz.riganid from dmingzhu mz 
where mingzhuid=@MingZhuId) as t1
left join zZhi z on t1.ZhiId = z.Zhiid ) as t2
left join vGanZhiGX ss1 on ss1.gxtypeid=3 and ss1.GanZhiId1 = t2.RiGanId and ss1.GanZhiId2 = t2.GanId
left join vGanZhiGX ss2 on ss2.gxtypeid=3 and ss2.GanZhiId1 = t2.RiGanId and ss2.GanZhiId2 = t2.ZhiCGanId1
left join vGanZhiGX ss3 on ss3.gxtypeid=3 and ss3.GanZhiId1 = t2.RiGanId and ss3.GanZhiId2 = t2.ZhiCGanId2
left join vGanZhiGX ss4 on ss4.gxtypeid=3 and ss4.GanZhiId1 = t2.RiGanId and ss4.GanZhiId2 = t2.ZhiCGanId3
left join zJiaZi jz on jz.jiaZiGanId = t2.GanId and jz.JiaZiZhiId = t2.ZhiId
left join vGanZhiGX ssgx on ssgx.gxtypeid=4 and ssgx.GanZhiId1 = t2.RiGanId and ssgx.GanZhiId2 = t2.ZhiId
where not exists (select 1 from zsuanming where skey='bzGanZhiType' and sdisabled=1 and skeyid=6)


	--神煞
	exec [dbo].[hFenXiShengSha] @MingZhuId

	--刑冲合害
	declare  @GanZhiGXTb table(
	 MingZhuId int,
	 GanZhiGXType nvarchar(50),
	 DYPeriod nvarchar(50),
	 year int,
	 GanZhiTypeId1 int,
	 Gan1 nvarchar(1),
	 Zhi1 nvarchar(1),
	 GanZhiTypeId2 int,
	 Gan2 nvarchar(1),
	 Zhi2 nvarchar(1),
	 GanZhiTypeId3 int,
	 Gan3 nvarchar(1),
	 Zhi3 nvarchar(1),
	 Remark nvarchar(50)
	)

	declare  @GanZhiGXTb2 table(
	 MingZhuId int,
	 GanZhiGXType nvarchar(50),
	 DYPeriod nvarchar(50),
	 year int,
	 GanZhiTypeId1 int,
	 Gan1 nvarchar(1),
	 Zhi1 nvarchar(1),
	 GanZhiTypeId2 int,
	 Gan2 nvarchar(1),
	 Zhi2 nvarchar(1),
	 GanZhiTypeId3 int,
	 Gan3 nvarchar(1),
	 Zhi3 nvarchar(1),
	 Remark nvarchar(50)
	)

insert into @GanZhiGXTb(MingZhuId,GanZhiGXType
,DYPeriod,Year,GanZhiTypeId1,Gan1,Zhi1,GanZhiTypeId2,Gan2,Zhi2,GanZhiTypeId3,Gan3,Zhi3,Remark)
select * from (
--1命2命
--1命2流
select bz1.MingZhuId,'干合冲' as GanZhiGXType, bz2.DYPeriod,bz2.Year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,bz2.GanZhiTypeId as GanZhiTypeId2,bz2.Gan as Gan2,bz2.Zhi as Zhi2
,null as GanZhiTypeId3,'' as Gan3,'' as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
inner join zganzhigx ggx on gxtypeid=1 and  ((bz1.ganid =ggx.ganzhiid1 and bz2.ganid=ggx.ganzhiid2)
or (bz1.ganid =ggx.ganzhiid2 and bz2.ganid=ggx.ganzhiid1))
where bz1.ganzhitypeid<>7 and bz1.mingzhuId=@MingZhuId
union
--1命2运
select distinct bz1.MingZhuId,'干合冲' as GanZhiGXType,bz2.DYPeriod,null as year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,5 as GanZhiTypeId2,bz2.DYGan as Gan2,bz2.DYZhi as Zhi2
,null as GanZhiTypeId3,'' as Gan3,'' as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
inner join zganzhigx ggx on gxtypeid=1 and  ((bz1.ganid =ggx.ganzhiid1 and bz2.DYGId=ggx.ganzhiid2)
or (bz1.ganid =ggx.ganzhiid2 and bz2.DYGId=ggx.ganzhiid1))
where bz1.ganzhitypeid<>7  and bz1.mingzhuId=@MingZhuId
union
--1命2命 - 支
--1命2流
select bz1.MingZhuId,'支邢冲合害' as GanZhiGXType, bz2.DYPeriod,bz2.Year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,bz2.GanZhiTypeId as GanZhiTypeId2,bz2.Gan as Gan2,bz2.Zhi as Zhi2
,null as GanZhiTypeId3,'' as Gan3,'' as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
inner join zganzhigx ggx on gxtypeid=2 and ganzhiid3 is  null and  ((bz1.zhiid =ggx.ganzhiid1 and bz2.zhiid=ggx.ganzhiid2)
or (bz1.zhiid =ggx.ganzhiid2 and bz2.zhiid=ggx.ganzhiid1))
where bz1.ganzhitypeid<>7 and bz1.mingzhuId=@MingZhuId
union
--1命2运 - 支
select distinct bz1.MingZhuId,'支邢冲合害' as GanZhiGXType,bz2.DYPeriod,null as year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,5 as GanZhiTypeId2,bz2.DYGan as Gan2,bz2.DYZhi as Zhi2
,null as GanZhiTypeId3,'' as Gan3,'' as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
inner join zganzhigx ggx on gxtypeid=2 and ganzhiid3 is  null and  ((bz1.zhiid =ggx.ganzhiid1 and bz2.DYZId=ggx.ganzhiid2)
or (bz1.zhiid =ggx.ganzhiid2 and bz2.DYZId=ggx.ganzhiid1))
where bz1.ganzhitypeid<>7  and bz1.mingzhuId=@MingZhuId
union
--1命2命3命
--1命2命3流
select bz1.MingZhuId,'支邢冲合害' as GanZhiGXType, bz3.DYPeriod as DYPeriod,bz3.year as Year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,bz2.GanZhiTypeId as GanZhiTypeId2,bz2.Gan as Gan2,bz2.Zhi as Zhi2
,bz3.GanZhiTypeId as GanZhiTypeId3,bz3.Gan as Gan3,bz3.Zhi as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
left join vbazi bz3 on bz1.mingzhuid=bz3.MingZhuId
inner join zganzhigx ggx on gxtypeid=2 and  ((bz1.zhiid =ggx.ganzhiid1 and bz2.zhiid=ggx.ganzhiid2 and bz3.zhiid=ggx.ganzhiid3)
or (bz2.zhiid =ggx.ganzhiid1 and bz3.zhiid=ggx.ganzhiid2 and bz1.zhiid=ggx.ganzhiid3) 
or (bz3.zhiid =ggx.ganzhiid1 and bz1.zhiid=ggx.ganzhiid2 and bz2.zhiid=ggx.ganzhiid3))
where bz1.ganzhitypeid<>7 and  bz2.ganzhitypeid<>7 and bz1.mingzhuId=@MingZhuId  
--1命2命3运
union
select distinct bz1.MingZhuId,'支邢冲合害' as GanZhiGXType, bz3.DYPeriod as DYPeriod,null as Year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,bz2.GanZhiTypeId as GanZhiTypeId2,bz2.Gan as Gan2,bz2.Zhi as Zhi2
,5 as GanZhiTypeId3,bz3.DYGan as Gan3,bz3.DYZhi as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
left join vbazi bz3 on bz1.mingzhuid=bz3.MingZhuId
inner join zganzhigx ggx on gxtypeid=2 and  ((bz1.zhiid =ggx.ganzhiid1 and bz2.zhiid=ggx.ganzhiid2 and bz3.DYZId=ggx.ganzhiid3)
or (bz2.zhiid =ggx.ganzhiid1 and bz3.DYZId=ggx.ganzhiid2 and bz1.zhiid=ggx.ganzhiid3) 
or (bz3.DYZId =ggx.ganzhiid1 and bz1.zhiid=ggx.ganzhiid2 and bz2.zhiid=ggx.ganzhiid3))
where bz1.ganzhitypeid<>7 and  bz2.ganzhitypeid<>7   and bz1.mingzhuId=@MingZhuId
--1命2运3流
union
select distinct bz1.MingZhuId,'支邢冲合害' as GanZhiGXType, bz3.DYPeriod as DYPeriod,bz3.year as  Year,bz1.GanZhiTypeId as GanZhiTypeId1,bz1.Gan as Gan1,bz1.Zhi as Zhi1
,5 as GanZhiTypeId2,bz2.DYGan as Gan2,bz2.DYZhi as Zhi2
,bz3.GanZhiTypeId as GanZhiTypeId3,bz3.Gan as Gan3,bz3.Zhi as Zhi3, ggx.Remark
from vbazi bz1
left join vbazi bz2 on bz1.mingzhuid=bz2.MingZhuId
left join vbazi bz3 on bz1.mingzhuid=bz3.MingZhuId and bz2.DYPeriod = bz3.DYPeriod
inner join zganzhigx ggx on gxtypeid=2 and  ((bz1.zhiid =ggx.ganzhiid1 and bz2.DYZId=ggx.ganzhiid2 and bz3.zhiid=ggx.ganzhiid3)
or (bz2.DYZId =ggx.ganzhiid1 and bz3.zhiid=ggx.ganzhiid2 and bz1.zhiid=ggx.ganzhiid3) 
or (bz3.zhiid =ggx.ganzhiid1 and bz1.zhiid=ggx.ganzhiid2 and bz2.DYZId=ggx.ganzhiid3))
where bz1.ganzhitypeid<>7  and bz1.mingzhuId=@MingZhuId
) as t

--删除干支分别在GanZhiType1和GanZhiType2交叉相同
delete gx1 from @GanZhiGXTb gx1 join  @GanZhiGXTb gx2 on gx1.mingzhuid=@MingZhuId and 
  isnull(gx1.dyperiod,'')=isnull(gx2.dyperiod,'') and isnull(gx1.year,'') = isnull(gx2.year,'') and gx1.GanZhiGXType = gx2.GanZhiGXType
and gx1.mingzhuid=gx2.mingzhuid and gx1.ganzhitypeid1=gx2.ganzhitypeid2 and gx1.ganzhitypeid2=gx2.ganzhitypeid1
and gx1.gan1=gx2.gan2 and gx1.zhi1=gx2.zhi2 and gx1.gan2=gx2.gan1 and gx1.zhi2=gx2.zhi1 and gx2.ganzhitypeid3 is null and gx1.ganzhitypeid3 is null;

--合并同一个period的干支作用
insert into @GanZhiGXTb2(MingZhuId,GanZhiGXType
,DYPeriod,Year,GanZhiTypeId1,Gan1,Zhi1,GanZhiTypeId2,Gan2,Zhi2,GanZhiTypeId3,Gan3,Zhi3,Remark)
select gx.mingzhuid,case CHARINDEX('干合冲', gx.ganzhigxtypes) when 0 then '支邢冲合害' else '干支动' end as GanZhiGXType,gx.dyperiod,gx.year
,gx.ganzhitypeid1,gx.gan1,gx.zhi1,gx.ganzhitypeid2,gx.gan2,gx.zhi2,gx.GanZhiTypeId3,gx.gan3,gx.zhi3
,substring(Remarks,0,len(remarks)) as Remarks from (
select mingzhuid,ganzhitypeid1,ganzhitypeid2,GanZhiTypeId3,dyperiod,year,gan1,zhi1,gan2,zhi2,gan3,zhi3
,(select isnull(gzgx2.ganzhigxtype,'')+';' from @GanZhiGXTb gzgx2 where gzgx.mingzhuid=gzgx2.mingzhuid --and gzgx.ganzhigxtype=gzgx2.ganzhigxtype 
and gzgx.ganzhitypeid1=gzgx2.ganzhitypeid1 and gzgx.ganzhitypeid2=gzgx2.ganzhitypeid2 and isnull(gzgx.GanZhiTypeId3,0)=isnull(gzgx2.GanZhiTypeId3,0)
and isnull(gzgx.dyperiod,'')=isnull(gzgx2.dyperiod,'') and isnull(gzgx.year,0)=isnull(gzgx2.year,0) and gzgx.gan1=gzgx2.gan1 and gzgx.zhi1=gzgx2.zhi1
and gzgx.gan2=gzgx2.gan2 and gzgx.zhi2=gzgx2.zhi2 and gzgx.gan3=gzgx2.gan3 and gzgx.zhi3=gzgx2.zhi3
for XML PATH('')) as ganzhigxtypes
,(select isnull(gzgx2.remark,'')+';' from @GanZhiGXTb gzgx2 where gzgx.mingzhuid=gzgx2.mingzhuid --and gzgx.ganzhigxtype=gzgx2.ganzhigxtype 
and gzgx.ganzhitypeid1=gzgx2.ganzhitypeid1 and gzgx.ganzhitypeid2=gzgx2.ganzhitypeid2 and isnull(gzgx.GanZhiTypeId3,0)=isnull(gzgx2.GanZhiTypeId3,0)
and isnull(gzgx.dyperiod,'')=isnull(gzgx2.dyperiod,'') and isnull(gzgx.year,0)=isnull(gzgx2.year,0) and gzgx.gan1=gzgx2.gan1 and gzgx.zhi1=gzgx2.zhi1
and gzgx.gan2=gzgx2.gan2 and gzgx.zhi2=gzgx2.zhi2 and gzgx.gan3=gzgx2.gan3 and gzgx.zhi3=gzgx2.zhi3
for XML PATH('')) as Remarks,count(1) as Cnt
 from @GanZhiGXTb gzgx where gzgx.mingzhuid=@MingZhuId 
 group by mingzhuid,ganzhitypeid1,ganzhitypeid2,ganzhitypeid3,dyperiod,year,gan1,zhi1,gan2,zhi2,gan3,zhi3
 ) as gx where cnt>1


 delete gx1 from @GanZhiGXTb gx1 join @GanZhiGXTb2 gx2 on gx1.mingzhuid=@MingZhuId and 
  isnull(gx1.dyperiod,'')=isnull(gx2.dyperiod,'') and isnull(gx1.year,'') = isnull(gx2.year,'') 
and gx1.mingzhuid=gx2.mingzhuid and gx1.ganzhitypeid1=gx2.ganzhitypeid1 and gx1.ganzhitypeid2=gx2.ganzhitypeid2 and isnull(gx1.ganzhitypeid3,0)=isnull(gx2.ganzhitypeid3,0)
and gx1.gan1=gx2.gan1 and gx1.zhi1=gx2.zhi1 and gx1.gan2=gx2.gan2 and gx1.zhi2=gx2.zhi2 and isnull(gx1.gan3,0)=isnull(gx2.gan3,0) and isnull(gx1.zhi3,0)=isnull(gx2.zhi3,0)

insert into @GanZhiGXTb 
select * from @GanZhiGXTb2

delete from @GanZhiGXTb2

--合并2个干支和3个干支里其中2个相同
insert into @GanZhiGXTb2(MingZhuId,GanZhiGXType
,DYPeriod,Year,GanZhiTypeId1,Gan1,Zhi1,GanZhiTypeId2,Gan2,Zhi2,GanZhiTypeId3,Gan3,Zhi3,Remark)
select gx1.mingzhuid,gx1.ganzhigxtype,gx1.dyperiod,gx1.year,gx2.ganzhitypeid1,gx2.gan1,gx2.zhi1,gx2.ganzhitypeid2,gx2.gan2,gx2.zhi2,gx2.ganzhitypeid3,gx2.gan3,gx2.zhi3,
gx1.remark +';'+gx2.remark as remark
from @GanZhiGXTb gx1  join 
@GanZhiGXTb gx2 on gx1.mingzhuid=gx2.mingzhuid and gx1.Ganzhitypeid3 is  null and gx2.Ganzhitypeid3 is not null and gx1.GanZhiGXType=gx2.GanZhiGXType
and isnull(gx1.DYPeriod,0)=isnull(gx2.DYPeriod,0) and isnull(gx1.Year,0)=isnull(gx2.Year,0)
and (convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2 = convert(nvarchar(10),gx2.GanZhiTypeId1)+gx2.Gan1+gx2.Zhi1+convert(nvarchar(10),gx2.GanZhiTypeId2)+gx2.Gan2+gx2.Zhi2
or convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2 = convert(nvarchar(10),gx2.GanZhiTypeId1)+gx2.Gan1+gx2.Zhi1+convert(nvarchar(10),isnull(gx2.GanZhiTypeId3,''))+gx2.Gan3+gx2.Zhi3
or convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2 = convert(nvarchar(10),gx2.GanZhiTypeId2)+gx2.Gan2+gx2.Zhi2+convert(nvarchar(10),isnull(gx2.GanZhiTypeId3,''))+gx2.Gan3+gx2.Zhi3)
 where gx1.mingzhuid=@MingZhuId

 --select * from @GanZhiGXTb
 --select * from @GanZhiGXTb2
 
delete gx1 from @GanZhiGXTb gx1 join @GanZhiGXTb2 gx2 on gx1.mingzhuid=@MingZhuId and 
gx1.mingzhuid=gx2.mingzhuid  and gx1.GanZhiGXType=gx2.GanZhiGXType --and gx1.Ganzhitypeid3 is  null  and gx2.Ganzhitypeid3 is not null
and  isnull(gx1.dyperiod,'')=isnull(gx2.dyperiod,'') and isnull(gx1.year,'') = isnull(gx2.year,'') 
and (convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2 = convert(nvarchar(10),gx2.GanZhiTypeId1)+gx2.Gan1+gx2.Zhi1+convert(nvarchar(10),gx2.GanZhiTypeId2)+gx2.Gan2+gx2.Zhi2
or convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2 = convert(nvarchar(10),gx2.GanZhiTypeId1)+gx2.Gan1+gx2.Zhi1+convert(nvarchar(10),isnull(gx2.GanZhiTypeId3,''))+gx2.Gan3+gx2.Zhi3
or convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2 = convert(nvarchar(10),gx2.GanZhiTypeId2)+gx2.Gan2+gx2.Zhi2+convert(nvarchar(10),isnull(gx2.GanZhiTypeId3,''))+gx2.Gan3+gx2.Zhi3
or convert(nvarchar(10),gx1.GanZhiTypeId1)+gx1.Gan1+gx1.Zhi1+convert(nvarchar(10),gx1.GanZhiTypeId2)+gx1.Gan2+gx1.Zhi2+convert(nvarchar(10),isnull(gx1.GanZhiTypeId3,0))+gx1.Gan3+gx1.Zhi3 
  =convert(nvarchar(10),gx2.GanZhiTypeId1)+gx2.Gan1+gx2.Zhi1+convert(nvarchar(10),gx2.GanZhiTypeId2)+gx2.Gan2+gx2.Zhi2+convert(nvarchar(10),isnull(gx2.GanZhiTypeId3,0))+gx2.Gan3+gx2.Zhi3)

  -- select * from @GanZhiGXTb

insert into @GanZhiGXTb 
select * from @GanZhiGXTb2

 insert into [dbo].[dMingZhuGZGX](mingzhu,GanZhiType1,GanZhiType2,GanZhiType3,MingZhuId,GanZhiGXType
	,DYPeriod,Year,GanZhiTypeId1,Gan1,Zhi1,GanZhiTypeId2,Gan2,Zhi2,GanZhiTypeId3,Gan3,Zhi3,Remark)
select mz.mingzhu,gzt1.svalue as GanZhiType1,gzt2.svalue as GanZhiType2,gzt3.svalue as GanZhiType3,t.* from @GanZhiGXTb t
left join zsuanming gzt1 on gzt1.skey='bzGanZhiType' and gzt1.skeyid=t.GanZhiTypeId1
left join zsuanming gzt2 on gzt2.skey='bzGanZhiType' and gzt2.skeyid=t.GanZhiTypeId2
left join zsuanming gzt3 on gzt3.skey='bzGanZhiType' and gzt3.skeyid=t.GanZhiTypeId3
left join dmingzhu mz on t.mingzhuid=mz.mingzhuid

END

GO
/****** Object:  StoredProcedure [dbo].[hFenXiGanZhiGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/4/27
-- Description:	刑冲合害
-- =============================================
CREATE PROCEDURE [dbo].[hFenXiGanZhiGX]
	-- Add the parameters for the stored procedure here
	@MingZhuId int
AS
BEGIN

	SET NOCOUNT ON;
	declare	@NBaZiId int,@YBaZiId int,@RBaZiId int,@SBaZiId int,@DBaZiId int = 0,@XBaZiId int = 0,@LBaZiId int = 0
	declare @tyear nvarchar(10),@tyearStr nvarchar(20),@dyyear varchar(4),@xyyear varchar(4),@lnyear varchar(4)

	select @NBaZiId = BaZiId from dBaZi where mingzhuid=@MingZhuId and  ganzhitypeid =1
	select @YBaZiId = BaZiId from dBaZi where mingzhuid=@MingZhuId and  ganzhitypeid =2
	select @RBaZiId = BaZiId from dBaZi where mingzhuid=@MingZhuId and  ganzhitypeid =3
	select @SBaZiId = BaZiId from dBaZi where mingzhuid=@MingZhuId and  ganzhitypeid =4

	declare  @tGanZhiGX table(
	  MingZhuId  int,
	  HitGanZhiTypeId1 int,
	  HitGanZhiTypeId2 int,
	  HitGanZhiTypeId3 int,
	  GanZhiGXId int,
	  Year nvarchar(10),
	  YearGanZhi nvarchar(20),
	  Remark nvarchar(50)

	)

	insert into @tGanZhiGX exec [dbo].[hGanZhiGX] @MingZhuId,@NBaZiId,@YBaZiId,@RBaZiId,@SBaZiId

	declare @SpecYear bit
	select @SpecYear = 1 from dMingZhu where MingZhuId = @MingZhuId and GongLi is not  null
	
	if(@SpecYear = 1)
	  begin
		DECLARE xybz_cursor CURSOR FOR
		SELECT BaZiId ,year , g.Gan + z.Zhi from dBaZi bz
		left join zgan g on bz.GanId = g.GanId 
		left join zzhi z on bz.ZhiId = z.ZhiId 
		WHERE mingzhuid=@MingZhuId and  ganzhitypeid =7
		ORDER BY BaZiSeq

		OPEN xybz_cursor

			-- Perform the first fetch.
			FETCH NEXT FROM xybz_cursor into @LBaZiId,@tyear,@lnyear

			-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
			WHILE @@FETCH_STATUS = 0
			BEGIN
			   -- This is executed as long as the previous fetch succeeds.
			   select @DBaZiId = BaZiId , @dyyear = g.Gan + z.Zhi from dBaZi bz
				left join zgan g on bz.GanId = g.GanId 
				left join zzhi z on bz.ZhiId = z.ZhiId where mingzhuid=@MingZhuId and  ganzhitypeid =5 
			   and year <= @tyear and @tyear < year +10
			   select @XBaZiId = BaZiId  , @xyyear = g.Gan + z.Zhi from dBaZi bz
				left join zgan g on bz.GanId = g.GanId 
				left join zzhi z on bz.ZhiId = z.ZhiId  where mingzhuid=@MingZhuId and  ganzhitypeid =6
			   and year = @tyear
			   set @tyearStr = '大运:'+isnull(@dyyear,'无')+' 小运:'+ @xyyear +' 流年:'+@lnyear
			   insert into @tGanZhiGX exec [dbo].[hGanZhiGX] @MingZhuId,@NBaZiId,@YBaZiId,@RBaZiId,@SBaZiId,@DBaZiId,@XBaZiId,@LBaZiId,@tyear,@tyearStr

			   FETCH NEXT FROM xybz_cursor into @LBaZiId,@tyear,@lnyear
			END

		CLOSE xybz_cursor
		DEALLOCATE xybz_cursor
	  end
	else 
	  begin 
	    
		DECLARE dy_cursor CURSOR FOR
		SELECT BaZiId  , g.Gan + z.Zhi,convert(nvarchar(10),bz.BaZiSeq) from dBaZi bz
		left join zgan g on bz.GanId = g.GanId 
		left join zzhi z on bz.ZhiId = z.ZhiId 
		WHERE mingzhuid=@MingZhuId and  ganzhitypeid =5
		ORDER BY BaZiSeq

		OPEN dy_cursor

			-- Perform the first fetch.
			FETCH NEXT FROM dy_cursor into @DBaZiId,@tyearStr,@tyear

			-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
			WHILE @@FETCH_STATUS = 0
			BEGIN

			  set @tyearStr = '大运:'+@tyearStr
		      insert into @tGanZhiGX exec [dbo].[hGanZhiGX] @MingZhuId,@NBaZiId,@YBaZiId,@RBaZiId,@SBaZiId,@DBaZiId,null,null,@tyear,@tyearStr

			   FETCH NEXT FROM dy_cursor into @DBaZiId,@tyearStr,@tyear
			END

		CLOSE dy_cursor
		DEALLOCATE dy_cursor


		DECLARE dy_cursor CURSOR FOR
		SELECT bz.BaZiId ,bz2.BaZiId , '小运:' + g.Gan + z.Zhi+' 流年:'+g2.Gan + z2.Zhi,convert(nvarchar(10),bz.BaZiSeq)+'岁' from dBaZi bz
		left join zgan g on bz.GanId = g.GanId 
		left join zzhi z on bz.ZhiId = z.ZhiId 
		left join dBaZi bz2 on bz.MingZhuId = bz2.MingZhuId and bz2.GanZhiTypeId = 7 and bz.BaZiSeq = bz2.BaZiSeq
		left join zgan g2 on bz2.GanId = g2.GanId 
		left join zzhi z2 on bz2.ZhiId = z2.ZhiId 
		WHERE bz.mingzhuid=@MingZhuId  and  bz.ganzhitypeid =6
		ORDER BY bz.BaZiSeq


		OPEN dy_cursor

			-- Perform the first fetch.
			FETCH NEXT FROM dy_cursor into @XBaZiId,@LBaZiId,@tyearStr,@tyear

			-- Check @@FETCH_STATUS to see if there are any more rows to fetch.
			WHILE @@FETCH_STATUS = 0
			BEGIN

		      insert into @tGanZhiGX exec [dbo].[hGanZhiGX] @MingZhuId,@NBaZiId,@YBaZiId,@RBaZiId,@SBaZiId,null,@XBaZiId,@LBaZiId,@tyear,@tyearStr

			   FETCH NEXT FROM dy_cursor into @XBaZiId,@LBaZiId,@tyearStr,@tyear
			END

		CLOSE dy_cursor
		DEALLOCATE dy_cursor
	   end 

	delete from [dbo].[dMingZhuDM] where mingzhuid=@MingZhuId
	insert into dMingZhuDM(MingzhuId,GanZhiGXId,Year,yearganzhi
	,GanZhiTypeId1,GanZhiTypeId2,GanZhiTypeId3
	,Remark)
	 select distinct mingzhuid,ganzhigxid,year,yearganzhi
	 ,HitGanZhiTypeId1,HitGanZhiTypeId2,HitGanZhiTypeId3
	,Remark from @tGanZhiGX

END

GO
/****** Object:  StoredProcedure [dbo].[hFenXiShengSha]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao	
-- Create date: 2016/4/27
-- Description:	shi sheng
-- =============================================
CREATE PROCEDURE [dbo].[hFenXiShengSha]
	-- Add the parameters for the stored procedure here
	@MingZhuId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 declare  @MingZhuSS table(
		 MingZhuId int,
		 ShengShaId int,
		 GanZhiTypeId int,
		 Remark nvarchar(50) )

	--年和日干查四柱
	insert into @MingZhuSS
	select t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
	--,t1.Ganid,t1.Zhiid,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4,t2.ShengSha 
	from (
	select MingZhuId ,GanZhiTypeId,ganid,zhiid from [dBaZi] bz where ganzhitypeid in (1,2,3,4) ) as t1
	,(select distinct MingZhuId,ss1.zhiid1,ss1.zhiid2,ss1.zhiid3,ss1.zhiid4,ss1.SNote as Remark,ss1.SKeyId as ShengShaId
	from [dBaZi] bz, zsetting  ss1
	 where   ss1.skey like 'bzshengsha%'  and ss1.typeid=6
	 and (bz.ganid=ss1.ganid1 or bz.ganid=ss1.ganid2) 
	and   mingzhuid=@MingZhuId and ganzhitypeid in (1,3) ) as t2
	where  t1.mingzhuid=@MingZhuId and t1.mingzhuid=t2.mingzhuid and 
	 (t1.zhiid=t2.zhiid1 or t1.zhiid=t2.zhiid2 or t1.zhiid=t2.zhiid3 or t1.zhiid=t2.zhiid4)
	  order by t1.GanZhiTypeId


	--年日支查四柱
	insert into @MingZhuSS
	 	select t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
	--,t1.Ganid,t1.Zhiid,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4 
	from (
	select MingZhuId ,GanZhiTypeId,ganid,zhiid from [dBaZi] bz where ganzhitypeid in (1,2,3,4) ) as t1
	,(select distinct MingZhuId,ss1.zhiid1,ss1.zhiid2,ss1.zhiid3,ss1.zhiid4,ss1.SNote as Remark,ss1.SKeyId as ShengShaId
	from [dBaZi] bz,zsetting  ss1
	 where  ss1.skey like 'bzshengsha%'  and ss1.typeid=11
	 and (bz.zhiid=ss1.zhiid1 or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3) 
	and   mingzhuid=@MingZhuId and ganzhitypeid in (1,3) ) as t2
	where  t1.mingzhuid=@MingZhuId and t1.mingzhuid=t2.mingzhuid and 
	t1.zhiid=t2.zhiid4
	  order by t1.GanZhiTypeId

	--与年支相冲的前一位地支
	insert into @MingZhuSS
		select bz.MingZhuID,29 as ShengShaId,bz.GanZhiTypeId
	--,bz.ganid,bz.zhiid,t2.zhiid5
	,'阳男阴女与年支相冲的前一地支为元辰，如是阴男阳女，即以年支相冲的后一位地支为元辰。' as Remark 
	from dBaZi bz ,
	(select (case when zhiid5<0 then zhiid5+12 when zhiid5>12 then zhiid5-12 else zhiid5 end) as zhiid5 from (
	select mz.nianzhiid,mz.xingbie,z.yingyangid
	,(case when mz.nianzhiid=zgx.ganzhiid1 then zgx.ganzhiid2+1 else zgx.ganzhiid1+1  end) as zhiid5 from dMingZhu mz,zzhi z,vganzhigx zgx 
	where mz.MingZhuId = @MingZhuId and  ganzhigxid=2 and mz.nianzhiid=z.zhiid
	 and (mz.nianzhiid=zgx.ganzhiid1 or mz.nianzhiid=zgx.ganzhiid2)
	 and ((z.yingyangid= 1 and mz.xingbie='男') or (z.yingyangid= 0 and mz.xingbie='女'))
	 union
	 select mz.nianzhiid,mz.xingbie,z.yingyangid
	,(case when mz.nianzhiid=zgx.ganzhiid1 then zgx.ganzhiid2-1 else zgx.ganzhiid1-1  end) as zhiid5 from dMingZhu mz,zzhi z,vganzhigx zgx 
	where mz.MingZhuId = @MingZhuId and  ganzhigxid=2 and mz.nianzhiid=z.zhiid
	 and (mz.nianzhiid=zgx.ganzhiid1 or mz.nianzhiid=zgx.ganzhiid2)
	 and ((z.yingyangid= 0 and mz.xingbie='男') or (z.yingyangid= 1 and mz.xingbie='女'))) as t) as t2
	 where bz.MingZhuId = @MingZhuId and bz.GanZhiTypeId in (1,2,3,4) and bz.zhiid = t2.zhiid5
	  
	--年支查前后n位

	 
	--年柱查四柱
	insert into @MingZhuSS
		select t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
	--,t1.Ganid,t1.Zhiid,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4 
	from (
	select MingZhuId ,GanZhiTypeId,ganid,zhiid from [dBaZi] bz where ganzhitypeid in (1,2,3,4) ) as t1
	,(select distinct MingZhuId,ss1.zhiid1,ss1.zhiid2,ss1.zhiid3,ss1.zhiid4,ss1.SNote as Remark,ss1.SKeyId as ShengShaId
	from [dBaZi] bz,zsetting  ss1
	 where  ss1.skey like 'bzshengsha%'  and ss1.typeid=12
	 and (bz.zhiid=ss1.zhiid1 or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3) 
	and   mingzhuid=@MingZhuId and ganzhitypeid in (1) ) as t2
	where  t1.mingzhuid=@MingZhuId and t1.mingzhuid=t2.mingzhuid and 
	t1.zhiid=t2.zhiid4
	  order by t1.GanZhiTypeId
	 
	--日干查四柱
	insert into @MingZhuSS
		  select bz.MingZhuId,t.ShengShaId,GanZhiTypeId
	  --,GanId,ZhiId
	  ,t.Remark from [dBaZi] bz,
	  (select GanZhiId2,case gxvalueid when 6 then '禄神' when 7 then '羊刃' end as Remark
	   ,case gxvalueid when 6 then 18 when 7 then 23 end as ShengShaId from dMingZhu mz
	  left join vGanZhiGX wsgx on wsgx.gxtypeid=4 and wsgx.GanZhiId1 = mz.RiGanId
	  where mz.MingZhuId = @MingZhuId and  gxvalueid in (6,7)) as t
	  where bz.MingZhuId = @MingZhuId and ganzhitypeid in (1,2,3,4) and zhiid = ganzhiid2;


	--日时柱查神煞
	with
 ss as 
(select ganid1,zhiid1,ssgx.skeyid as shengshaid,snote as remark from zsetting ssgx where ssgx.skeyid=38
)
insert into @MingZhuSS
select t.MingZhuId,t.ShengShaId,t1.GanZhiTypeId,t.Remark from (
select 
--riganid,rizhiid,shiganid,shizhiid,
mz.MingZhuId,38 as shengshaid,'' as remark from dMingZhu mz
where mz.MingZhuId = @MingZhuId 
and exists(select 1 from ss where mz.riganid=ss.ganid1 and mz.rizhiid=ss.zhiid1)
and exists(select 1 from ss where mz.shiganid=ss.ganid1 and mz.shizhiid=ss.zhiid1)
union 
select 
--riganid,rizhiid,shiganid,shizhiid
mz.MingZhuId,skeyid as shengshaid,snote as remark from dMingZhu mz , zsetting ssgx
where mz.mingzhuid=@MingZhuId and ssgx.skey like 'bzshengsha%' and ssgx.skeyid=19 and 
( (riganid=ssgx.ganid1 and rizhiid=ssgx.zhiid1 and shiganid=ssgx.ganid2 and shizhiid=ssgx.zhiid2)
or (riganid=ssgx.ganid3 and rizhiid=ssgx.zhiid3 and shiganid=ssgx.ganid4 and shizhiid=ssgx.zhiid4))) as t,
(select @MingZhuId as MingZhuId,3 as GanZhiTypeId
union
select @MingZhuId as MingZhuId,4 as GanZhiTypeId) as t1 where t.MingZhuId = t1.MingZhuId
 
	--日旬查四柱
	insert into @MingZhuSS
	select bz.MingZhuId,35 as ShengShaId,bz.GanZhiTypeId,'日柱空亡' as Remark
--,bz.GanId,bz.ZhiId,t.KWZhi1,t.KWZhi2 
from dbazi bz ,
(select mza.KongWangZhiId1 as kwzhi1,mza.KongWangZhiId2 as kwzhi2 from dMingZhu mz , dMingZhuAdd mza
where mz.mingzhuid=@MingZhuId and  mz.mingzhuid =mza.mingzhuid) as t
where bz.mingzhuid=@MingZhuId and bz.GanZhiTypeId in (1,2,3,4,9)
and (bz.zhiid=kwzhi1 or bz.zhiid=kwzhi2)


	--日柱查神煞 
	insert into @MingZhuSS
		  select  mz.MingZhuId,ssgx.skeyid as ShengShaId,3 as GanZhiTypeId,ssgx.snote as Remark
	  --ssgx.GanId4,ssgx.ZhiId1,ssgx.Zhiid2,ssgx.ZhiId3,ssgx.ZhiId4,ShengSha 
	  from dMingZhu mz,zsetting ssgx
	  where mz.MingZhuId = @MingZhuId and  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=15
	  and (mz.YueZhiid=ssgx.zhiid1 or mz.YueZhiid=ssgx.zhiid2 or mz.YueZhiid=ssgx.zhiid3)
	  and ((RiGanId = ssgx.GanId1 and RiZhiId = ssgx.ZhiId1)
	  or (RiGanId = ssgx.GanId2 and RiZhiId = ssgx.ZhiId2)
	  or (RiGanId = ssgx.GanId3 and RiZhiId = ssgx.ZhiId3)
	  or (RiGanId = ssgx.GanId4 and RiZhiId = ssgx.ZhiId4))


	--三干相连查神煞
	insert into @MingZhuSS
	 select bz.MingZhuId,7 as  ShengShaId,1 as GanZhiTypeId,Remark
 --,GanId1,GanId2,GanId3 
 from [dMingZhu] bz
	   ,(select ss.GanId1,ss.GanId2,ss.GanId3,ss.snote as Remark from zsetting ss
	    where  ss.skey like 'bzshengsha%'  and ss.typeid=7) as t
	  where mingzhuid=@MingZhuId and ((bz.NianGanId = t.GanId1 and bz.YueGanId = t.GanId2 and bz.RiGanId = t.GanId3)
	  or (bz.YueGanId = t.GanId1 and bz.RiGanId = t.GanId2 and bz.ShiGanId = t.GanId3))

	--时柱查神煞
	insert into @MingZhuSS
		  select  mz.MingZhuId,ssgx.skeyid as ShengShaId,4 as GanZhiTypeId,ssgx.snote as Remark
	 -- ssgx.GanId4,ssgx.ZhiId1,ssgx.Zhiid2,ssgx.ZhiId3,ssgx.ZhiId4,ShengSha 
	  from dMingZhu mz,zsetting ssgx
	  where mz.MingZhuId = @MingZhuId and  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=16
	  and (mz.YueZhiid=ssgx.zhiid1 or mz.YueZhiid=ssgx.zhiid2 or mz.YueZhiid=ssgx.zhiid3)
	  and ((ShiGanId = ssgx.GanId1 and ShiZhiId = ssgx.ZhiId1)
	  or (ShiGanId = ssgx.GanId2 and ShiZhiId = ssgx.ZhiId2)
	  or (ShiGanId = ssgx.GanId3 and ShiZhiId = ssgx.ZhiId3)
	  or (ShiGanId = ssgx.GanId4 and ShiZhiId = ssgx.ZhiId4));


	--月支查干
	with 
bz as 
( 
    select GanZhiTypeId,GanId,ZhiId from dBaZi  where MingZhuId = @MingZhuId and GanZhiTypeId in (1,2,3,4)
) 
insert into @MingZhuSS
select t.mingzhuid,t.skeyid as ShengShaId,bz.GanZhiTypeId,t.snote as Remark from (
select mz.mingzhuid,ssgx.*from dMingZhu mz,zsetting ssgx
where  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=20
and mz.mingzhuid=@MingZhuId and  (mz.yuezhiid=ssgx.zhiid1 or mz.yuezhiid=ssgx.zhiid2 or mz.yuezhiid=ssgx.zhiid3 )
and exists(select 1 from bz where bz.ganid=ganid1)
and exists(select 1 from bz where bz.ganid=ganid2)) as t,bz
where (bz.GanId=t.GanId3 or  bz.GanId=t.GanId4)

	--月支查日柱 
	insert into @MingZhuSS
	select  mz.MingZhuId,ssgx.skeyid as ShengShaId,3 as GanZhiTypeId,ssgx.snote as Remark
--ssgx.GanId4,ssgx.ZhiId1,ssgx.Zhiid2,ssgx.ZhiId3,ssgx.ZhiId4,ShengSha 
from dMingZhu mz,zsetting ssgx
	  where mz.MingZhuId = @MingZhuId and  ssgx.skey like 'bzshengsha%'  and ssgx.typeid=14
	  and (mz.YueZhiid=ssgx.zhiid1 or mz.YueZhiid=ssgx.zhiid2 or mz.YueZhiid=ssgx.zhiid3)
	  and RiGanId = ssgx.GanId4 and RiZhiId = ssgx.ZhiId4

	--月支查四柱
	insert into @MingZhuSS
	select t1.MingZhuId,t2.ShengShaId,GanZhiTypeId,t2.Remark
--,t1.Ganid,t1.Zhiid,t2.Remark,t2.ganid1,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4,ShengSha
 from (
select MingZhuId ,GanZhiTypeId,ganid,zhiid from [dBaZi] bz where ganzhitypeid in (1,2,3,4) ) as t1
,(select MingZhuId,ganid,zhiid,ganid1,zhiid1,zhiid2,zhiid3,zhiid4,snote as remark,skeyid as shengshaId
from [dBaZi] bz, zsetting ss1
	 where  ss1.skey like 'bzshengsha%'  and ss1.typeid=8
 and (bz.zhiid=ss1.zhiid1  or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3 ) 
and  mingzhuid= @MingZhuId and ganzhitypeid in (2) ) as t2
where t1.mingzhuid= @MingZhuId and t1.mingzhuid=t2.mingzhuid and 
 (t1.ganid = t2.ganid1 or t1.zhiid=t2.zhiid4) order by t1.GanZhiTypeId

	--以月支查四柱干支相合者
	insert into @MingZhuSS
	select t1.MingZhuId
--,t1.Ganid,t1.Zhiid,t2.ganid1,t2.zhiid1,t2.zhiid2,t2.zhiid3,t2.zhiid4,ganid5,zhiid5
,case t2.shengshaid when 3 then 5 when 4 then 6 end as shengshaId,t1.GanZhiTypeId
,t2.Remark+char(13)+remark2  as remark from (
select MingZhuId ,GanZhiTypeId,ganid,zhiid from [dBaZi] bz where ganzhitypeid in (1,2,3,4) ) as t1
,(select MingZhuId,ganid,zhiid,ganid1,zhiid1,zhiid2,zhiid3,zhiid4,ganid5,zhiid5,snote as remark,remark2,skeyid as shengshaid
from [dBaZi] bz, 
( select ssgx.*
	 ,case when ssgx.ganid1=ggx.ganzhiid1 then ggx.ganzhiid2 else ggx.ganzhiid1 end as ganid5
	 ,case when ssgx.zhiid4=zgx.ganzhiid1 then zgx.ganzhiid2 else zgx.ganzhiid1 end as zhiid5
	 ,isnull(ggx.remark,zgx.remark) as remark2
	  from zsetting ssgx
	  left join vganzhigx ggx on  (ssgx.ganid1= ggx.GanzhiId1 or ssgx.ganid1= ggx.GanzhiId2 ) and ggx.ganzhigxid=1
	  left join vganzhigx zgx on  (ssgx.zhiid4 = zgx.GanzhiId1 or ssgx.zhiid4 = zgx.GanzhiId2) and zgx.ganzhigxid=1
	  where skeyid  in (3,4)
) as  ss1  where (bz.zhiid=ss1.zhiid1  or bz.zhiid=ss1.zhiid2 or bz.zhiid=ss1.zhiid3 ) 
and  mingzhuid= @MingZhuId and ganzhitypeid in (2) ) as t2
where t1.mingzhuid= @MingZhuId and t1.mingzhuid=t2.mingzhuid and 
 (t1.ganid = t2.ganid5 or t1.zhiid=t2.zhiid5) order by t1.GanZhiTypeId


	delete from dMingZhuSS where MingZhuId = @MingZhuId
	insert into dMingZhuSS([MingZhuId],[ShengShaId],[GanZhiTypeId],[Remark]) select * from @MingZhuSS


END

GO
/****** Object:  StoredProcedure [dbo].[hGanZhiGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/4/27
-- Description:	刑冲合害
-- =============================================
CREATE PROCEDURE [dbo].[hGanZhiGX]
	-- Add the parameters for the stored procedure here
	@MingZhuId int,
	@NBaZiId int,
	@YBaZiId int,
	@RBaZiId int,
	@SBaZiId int,
	@DBaZiId int = 0,
	@XBaZiId int = 0,
	@LBaZiId int = 0,
	@Year nvarchar(10) = '',
	@YearGanZhi nvarchar(20) = ''
AS
BEGIN
	SET NOCOUNT ON;

	with bz as (
	select baziid,ganid,zhiid,ganzhitypeid,year,baziseq from dbazi where baziid in (@NBaZiId,@YBaZiId,@RBaZiId,@SBaZiId,@DBaZiId,@XBaZiId,@LBaZiId)
	)
	select * from (
	select @MingZhuId as MingZhuId
	--,t1.BaZiId as HitBaZiId1,t2.BaZiId as HitBaZiId2,null as HitBaZiId3
	,t1.GanZhiTypeId as HitGanZhiTypeId1,t2.GanZhiTypeId as HitGanZhiTypeId2,null as HitGanZhiTypeId3
	, t1.GanZhiGXId,@Year as Year,@YearGanZhi as YearGanZhi,t1.Remark
	 from 
	(select * from bz 
	left join vganzhigx ggx1 on bz.ganid=ggx1.ganzhiid1 and ggx1.gxtypeid=1) as t1,
	(select * from bz 
	left join vganzhigx ggx2 on bz.ganid=ggx2.ganzhiid2 and ggx2.gxtypeid=1) as t2
	where t1.gxid = t2.gxid and t1.BaZiId != t2.BaZiId ) as nt1
	union
	select * from (
	select @MingZhuId as MingZhuId
	--,t1.BaZiId as HitBaZiId1,t2.BaZiId as HitBaZiId2,null as HitBaZiId3
	,t1.GanZhiTypeId as HitGanZhiTypeId1,t2.GanZhiTypeId as HitGanZhiTypeId2,null as HitGanZhiTypeId3
	, t1.GanZhiGXId,@Year as Year,@YearGanZhi as YearGanZhi,t1.Remark
	 from 
	(select * from bz 
	left join vganzhigx zzx1 on bz.zhiid=zzx1.ganzhiid1 and zzx1.ganZhiId3 is null  and zzx1.gxtypeid=2) as t1,
	(select * from bz 
	left join vganzhigx zzx2 on bz.zhiid=zzx2.ganzhiid2 and zzx2.ganZhiId3 is null  and zzx2.gxtypeid=2) as t2
	where t1.gxid = t2.gxid and t1.BaZiId != t2.BaZiId ) as nt2
	union
	select * from (
	select @MingZhuId as MingZhuId
	--,t1.BaZiId as HitBaZiId1,t2.BaZiId as HitBaZiId2,t3.BaZiId as HitBaZiId3
	,t1.GanZhiTypeId as HitGanZhiTypeId1,t2.GanZhiTypeId as HitGanZhiTypeId2,t3.GanZhiTypeId as HitGanZhiTypeId3
	, t1.GanZhiGXId,@Year as Year,@YearGanZhi as YearGanZhi,t1.Remark
	 from 
	(select * from bz 
	left join vganzhigx zzx1 on bz.zhiid=zzx1.ganzhiid1 and zzx1.ganZhiId3 is not  null and zzx1.gxtypeid=2 ) as t1,
	(select * from bz 
	left join vganzhigx zzx2 on bz.zhiid=zzx2.ganzhiid2 and zzx2.ganZhiId3 is not  null and zzx2.gxtypeid=2) as t2
	,(select * from bz 
	left join vganzhigx zzx3 on bz.zhiid=zzx3.ganzhiid3 and zzx3.ganZhiId3 is not  null and zzx3.gxtypeid=2) as t3
	where t1.gxid = t2.gxid and t1.BaZiId != t2.BaZiId  and t2.gxid = t3.gxid) as nt3

END

GO
/****** Object:  StoredProcedure [dbo].[wZiWeiForDiffType]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		小猫
-- Create date: 2016/4/17
-- Description:	紫薇排盘
-- =============================================
CREATE PROCEDURE [dbo].[wZiWeiForDiffType]
    @MingZhuId int,
    @PaiPanTypeId int,
	@MGZhiId int ,
	@SGZhiId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @NongLiYue int ,@NianGanId int,@NianZhiId int,@NongLiRi int,@ShiZhiId  int ,@IsShun bit
    select @NongLiYue=NongLiYue,@NianGanId=NianGanId,@NianZhiId=NianZhiId,@NongLiRi=NongLiRi,@ShiZhiId=ShiZhiId ,@IsShun=IsShun from dmingzhu  where mingzhuid=@MingZhuId

	--命盘
	if @PaiPanTypeId =1
	begin
		delete from dZiWeiXingYao where ZiWeiId in (select ZiWeiId from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId)
		delete from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId
		delete from dMingZhuZWAdd  where MingZhuId=@MingZhuId

		--1.定命身宫
		set @MGZhiId = dbo.fZhiOffset(@NongLiYue+2,@ShiZhiId,0) 
		set @SGZhiId = dbo.fZhiOffset(@NongLiYue+2,@ShiZhiId,1)
	end

	create  table #tmptb(GongWeiId int, GanId int,ZhiId int)
	
	--2.定十二宫
　  INSERT INTO #tmptb(GongWeiId,ZhiId)
    select SKeyId as GongWeiId, dbo.fZhiOffset(@MGZhiId,SKeyId,1) as ZhiId from zsuanming gw where gw.skey='zwGongWei' and gw.SKeyId<13

	--3.安十二宫天干
	Update #tmptb  set GanId=ny.YueGanId from vNianToYue ny where #tmptb.ZhiId = ny.YueZhiId 
	and (ny.GanId1 = @NianGanId or ny.GanId2 = @NianGanId)

	--select g.Gan,z.Zhi,* from #tmptb tb
	--left join wGongWei gw on tb.GongWeiId = gw.GongWeiId
	--left join zGan g on tb.GanId = g.GanId
	--left join zZhi z on tb.ZhiId = z.ZhiId
	insert into dZiWei(MingZhuId,PaiPanTypeId,GongWeiId,GanId,ZhiId)
	select @MingZhuId,@PaiPanTypeId,GongWeiId,GanId,ZhiId from #tmptb where not exists
	(select 1 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId)

	--身宫
	update dZiWei set IsShengGong = 1 where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId
	and @SGZhiId=dZiWei.ZhiId


	--4.定五行局
	declare @JuShu int,@WuHangId int,@YueGanId int,@YueZhiId int
	select @JuShu=wh.JuShu,@WuHangId = wh.WuHangId from vJiaZi jz 
	inner join #tmptb tb on tb.GongWeiId =1 and jz.JiaZiGanid = tb.GanId and jz.jiaziZhiId=tb.zhiid
	left join zWuHang wh on wh.WuHangId = jz.wuhangid

	select @YueGanId=YueGanId,@YueZhiId=YueZhiId from vNianToYue where yuezhiid=[dbo].[fZhiOffset] (@NongLiYue,3,1)
	and (Ganid1=@NianGanId or Ganid2=@NianGanId)

	insert into dMingZhuZWAdd(mingzhuid,wuhangid,yueganid,yuezhiid) values(@MingZhuId,@WuHangId,@YueGanId,@YueZhiId)

	--select @JuShu

	--5.起大限
	if @IsShun = 1
	  update dZiWei set DaXianFrom = @JuShu+(gw.SKeyId-1)*10,DaXianTo=@JuShu+(gw.SKeyId-1)*10+9 from zsuanming gw where mingzhuid=@MingZhuId and gw.skey='zwGongWei' and dZiWei.GongWeiId=gw.SKeyId
	else
	  update dZiWei set DaXianFrom = @JuShu+(gw2.SKeyId-1)*10,DaXianTo=@JuShu+(gw2.SKeyId-1)*10+9 from zsuanming gw ,zsuanming gw2  where gw.skeyid=dZiWei.GongWeiId and gw.svalue=gw2.svalue and 
    mingzhuid=@MingZhuId and gw.skey='zwGongWei' and gw2.skey='zwGongWeiNi' and dZiWei.GongWeiId=gw.SKeyId 


	--6.起紫薇星
	declare @Yu int,@Shang int,@ZiWeiZhiId int,@StartZhiId int
	set @Yu = @NongLiRi%@JuShu
	set @Shang=@NongLiRi/@JuShu
	if @Yu = 0 
	begin
	    set @ZiWeiZhiId = 3   -- 寅宫
	end
	else 
	begin
	    if (@JuShu=2 and @Yu=1) or (@JuShu=3 and @Yu=2) or  (@JuShu=4 and @Yu=3) or (@JuShu=5 and @Yu=4) or (@JuShu=6 and @Yu=5) 
		   begin  set @StartZhiId = 2 end   -- 丑宫
        if (@JuShu=3 and @Yu=1) or (@JuShu=4 and @Yu=2) or  (@JuShu=5 and @Yu=3) or (@JuShu=6 and @Yu=4) 
		   begin  set @StartZhiId = 5 end   -- 辰宫
		if (@JuShu=4 and @Yu=1) or (@JuShu=5 and @Yu=2) or  (@JuShu=6 and @Yu=3) 
		   begin  set @StartZhiId = 12 end   -- 亥宫
		if (@JuShu=5 and @Yu=1) or (@JuShu=6 and @Yu=2) 
		   begin  set @StartZhiId = 7 end   -- 午宫
		if (@JuShu=6 and @Yu=1) 
		   begin  set @StartZhiId = 10 end   -- 酉宫
		 set @ZiWeiZhiId = dbo.fZhiOffset(@StartZhiId+1,@Shang,1)
	end 	
	--select @StartZhiId,@ZiWeiZhiId,@Shang,@Yu

	--7.安天府
	declare @TianFuZhiId int
	if @ZiWeiZhiId = 3 or @ZiWeiZhiId = 9
	begin set @TianFuZhiId = @ZiWeiZhiId end
	else
	begin
	   if @ZiWeiZhiId < 6
	   begin set @TianFuZhiId = 6-@ZiWeiZhiId end 
	   else
	   begin set @TianFuZhiId = 18-@ZiWeiZhiId end 
	end
	--select @ZiWeiZhiId,@TianFuZhiId

	--8.安十四正曜
	delete from dZiWeiXingYao where ZiWeiId in (select ZiWeiId from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId)
	--紫薇
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,1 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=@ZiWeiZhiId
	--天机
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,2 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@ZiWeiZhiId,2,0)  
	--太阳
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,3 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@ZiWeiZhiId,4,0)  
	--武曲
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,4 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@ZiWeiZhiId,5,0)  
	--天同
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,5 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@ZiWeiZhiId,6,0)  
	--廉贞
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,6 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@ZiWeiZhiId,9,0)  
	--天府
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,7 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=@TianFuZhiId 
	--太阴
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,8 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,2,1)
	--贪狼
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,9 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,3,1)
	--巨门
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,10 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,4,1)
	--天相
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,11 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,5,1)
	--天梁
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,12 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,6,1)
	--七杀
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,13 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,7,1)
	--破军
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,14 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(@TianFuZhiId,11,1)
	
	--9.左辅右弼
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,19 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(5,@NongLiYue,1)
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,20 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(11,@NongLiYue,0)
	
	--文曲文昌
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,23 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(11,@ShiZhiId,0)
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,24 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(5,@ShiZhiId,1)
	
	--地劫地空
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,27 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(12,@ShiZhiId,1)
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,28 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId=dbo.fZhiOffset(12,@ShiZhiId,0)

	--10.安四化星
	update dZiWei set HuaLuXYId= sh.HLX,HuaQuanXYId=HQX,HuaKeXYId=HKX,HuaJiXYId=HJX from vSiHua sh
    where dZiWei.GanId=sh.GanId 
	and dZiWei.MingZhuId=@MingZhuId and dZiWei.PaiPanTypeId=@PaiPanTypeId

    --安四化星宫位
	update dZiWei set HuaLuGWId=t.HLGongWeiId,HuaQuanGWId=t.HQGongWeiId
	,HuaKeGWId=t.HKGongWeiId,HuaJiGWId=t.HJGongWeiId from (
	select dZiWei.ZiWeiId ,zwhl.GongWeiId as HLGongWeiId, zwhq.GongWeiId as HQGongWeiId
	,zwhk.GongWeiId as HKGongWeiId,zwhj.GongWeiId as HJGongWeiId from dZiWei
	inner join dZiWeiXingYao zwxyhl on dZiWei.HuaLuXYId = zwxyhl.XingYaoId
	inner join dZiWei zwhl on zwhl.ZiWeiId = zwxyhl.ZiWeiId and zwhl.MingZhuId=@MingZhuId and zwhl.PaiPanTypeId=@PaiPanTypeId
	inner join dZiWeiXingYao zwxyhq on dZiWei.HuaQuanXYId = zwxyhq.XingYaoId
	inner join dZiWei zwhq on zwhq.ZiWeiId = zwxyhq.ZiWeiId and zwhq.MingZhuId=@MingZhuId and zwhq.PaiPanTypeId=@PaiPanTypeId
	inner join dZiWeiXingYao zwxyhk on dZiWei.HuaKeXYId = zwxyhk.XingYaoId
	inner join dZiWei zwhk on zwhk.ZiWeiId = zwxyhk.ZiWeiId and zwhk.MingZhuId=@MingZhuId and zwhk.PaiPanTypeId=@PaiPanTypeId
	inner join dZiWeiXingYao zwxyhj on dZiWei.HuaJiXYId = zwxyhj.XingYaoId
	inner join dZiWei zwhj on zwhj.ZiWeiId = zwxyhj.ZiWeiId and zwhj.MingZhuId=@MingZhuId and zwhj.PaiPanTypeId=@PaiPanTypeId
	where dZiWei.MingZhuId=@MingZhuId and dZiWei.PaiPanTypeId=@PaiPanTypeId 
	) as t where dZiWei.ZiWeiId = t.ZiWeiId


	--TypeId '1' : 依年干定,'2':依年支定,'3':从某宫起年支,'4':某宫起月份,'5':依月份定
	--11.天魁,天钺,12.禄存,14.天福,天官,15.天厨
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=1 and zw.ZhiId = s.ZhiId1
	and zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId 
	and ( s.GanId1=@NianGanId or s.GanId2=@NianGanId or s.GanId3=@NianGanId or s.GanId4=@NianGanId)
	
	--18.天马,21.孤辰,寡宿,24.蜚廉,华盖,破碎,咸池
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=2 and s.skey not in ('zwHuoXing','zwLingXing') 
	and zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId 
	and zw.ZhiId = s.ZhiId4 and ( s.ZhiId1=@NianZhiId or s.ZhiId2=@NianZhiId or s.ZhiId3=@NianZhiId)

	--19.天哭,天虚,20.红鸾,天喜,24.龙德,月德,25.年德,天德,27.龙池,凤阁,
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=3 
	and zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId 
	and zw.ZhiId = dbo.fZhiOffset(s.ZhiId1,@NianZhiId,s.ShunNi)

	--29.天刑,天姚
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=4
	and zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId 
	and zw.ZhiId = dbo.fZhiOffset(s.ZhiId1,@NongLiYue,s.ShunNi)

	--30.解神,天巫,31.天月,32.阴煞
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,s.XingYaoId from dZiWei zw ,zSetting s where s.typeid=5
	and zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId 
	and zw.ZhiId = s.ZhiId4 and ( s.ZhiId1=@NongLiYue or s.ZhiId2=@NongLiYue or s.ZhiId3=@NongLiYue)

	--return

	--12.定羊，陀
	declare @LuCunZhiId int
	select @LuCunZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=25
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,17 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@LuCunZhiId,2,1) 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,18 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@LuCunZhiId,2,0) 

	--13.定火星，铃星
	declare @HuoStartZhiId int,@LingStartZhiId int
	select @HuoStartZhiId=ZhiId4 from zSetting where skey='zwHuoXing' and( ZhiId1=@NianZhiId or ZhiId2=@NianZhiId or ZhiId3=@NianZhiId)
	select @LingStartZhiId=ZhiId4 from zSetting where skey='zwLingXing' and( ZhiId1=@NianZhiId or ZhiId2=@NianZhiId or ZhiId3=@NianZhiId)
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,15 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@HuoStartZhiId,@ShiZhiId,1) 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,16 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@LingStartZhiId,@ShiZhiId,1) 

	--16.安截空
	declare @JieKongZhiId int,@JieKongZhiId1 int,@JieKongZhiId2 int
	select @JieKongZhiId1=ZhiId1,@JieKongZhiId2=ZhiId2 from zSetting where skey='zwJieKong' and (GanId1=@NianGanId or GanId2=@NianGanId)
	if @NianGanId%2 = @JieKongZhiId1%2 set @JieKongZhiId=@JieKongZhiId1
	if @NianGanId%2 = @JieKongZhiId2%2 set @JieKongZhiId=@JieKongZhiId2
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,48 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = @JieKongZhiId

	--17.安旬空？
	--18.安天空
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,46 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@NianZhiId,2,1) 
	--22.安劫煞
	declare @HuaGaiZhiId int
	select @HuaGaiZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=39
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,116 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@HuaGaiZhiId,2,0) 
	--23.安大耗？
	--26.安天才天寿
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,40 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@MGZhiId,@NianZhiId,1) 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,41 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@SGZhiId,@NianZhiId,1) 
	--28.安台辅封诰
	declare @WenChangZhiId int,@WenQuZhiId int
	select @WenChangZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=23
	select @WenQuZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=24
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,56 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@WenQuZhiId,3,1) 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,57 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@WenQuZhiId,3,0) 
	--33.安伤使
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select zw.ZiWeiId,117 from dZiWei zw where  MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and zw.GongWeiId = (case @IsShun when 1 then 6  when 0 then 8 end)
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select zw.ZiWeiId,118 from dZiWei zw where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and zw.GongWeiId = (case @IsShun when 1 then 8  when 0 then 6 end)
	--34.安三台八座
	declare @ZuoFuZhiId int,@YouBiZhiId int
	select @ZuoFuZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=19
	select @YouBiZhiId=zw.ZhiId from dZiWei zw,dZiWeiXingYao zwxy where zw.ZiWeiId = zwxy.ZiWeiId and zwxy.XingYaoId=20
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,58 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@ZuoFuZhiId,@NongLiRi,1) 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,59 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@YouBiZhiId,@NongLiRi,0) 
	--34.安恩光天贵
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,60 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@WenChangZhiId,@NongLiRi-1,1) 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select ZiWeiId,61 from dZiWei where MingZhuId=@MingZhuId and PaiPanTypeId=@PaiPanTypeId and ZhiId = dbo.fZhiOffset(@WenQuZhiId,@NongLiRi-1,1) 
	--36.安命主
	--37.安身主
	--38.安长生十二神
	declare @ChangShengStartZhiId int
	if @JuShu = 2 or @JuShu = 5 set  @ChangShengStartZhiId = 9
	if @JuShu = 4 set  @ChangShengStartZhiId = 6
	if @JuShu = 6 set  @ChangShengStartZhiId = 3
	if @JuShu = 3 set  @ChangShengStartZhiId = 12
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select zw.ZiWeiId,xy.XingYaoId from dZiWei zw,wXingYao xy where zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId
	and  xy.XingYaoTypeId=5 and zw.ZhiId = dbo.fZhiOffset(@ChangShengStartZhiId,xy.XingYaoId-65,@IsShun) 
	order by xy.XingYaoId
	--41.安生年博士十二神?
	declare @BoShieStartZhiId int
	select @BoShieStartZhiId = ganzhiid2 from [dbo].[vGanZhiGX] where gxtypeid=4 and ganzhiid1=@NianGanId and gxvalue='临官' 
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select zw.ZiWeiId,xy.XingYaoId from dZiWei zw,wXingYao xy where zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId
	and  xy.XingYaoTypeId=8 and zw.ZhiId = dbo.fZhiOffset(@BoShieStartZhiId,xy.XingYaoId-101,@IsShun) 
	order by xy.XingYaoId
    --39.安太岁十二神
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select zw.ZiWeiId,xy.XingYaoId from dZiWei zw,wXingYao xy where zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId
	and  xy.XingYaoTypeId=6 and zw.ZhiId = dbo.fZhiOffset(@NianZhiId,xy.XingYaoId-77,1) 
	order by xy.XingYaoId
	--40.安将前诸星
	declare @JiangQianStartZhiId int
	select @JiangQianStartZhiId=ZhiId4 from zSetting where skey='zwJiangQian' and( ZhiId1=@NianZhiId or ZhiId2=@NianZhiId or ZhiId3=@NianZhiId)
	insert into dZiWeiXingYao(ZiWeiId,XingYaoId) 
	select zw.ZiWeiId,xy.XingYaoId from dZiWei zw,wXingYao xy where zw.MingZhuId=@MingZhuId and zw.PaiPanTypeId=@PaiPanTypeId
	and  xy.XingYaoTypeId=7 and zw.ZhiId = dbo.fZhiOffset(@JiangQianStartZhiId,xy.XingYaoId-89,1) 
	order by xy.XingYaoId
	
END

GO
/****** Object:  StoredProcedure [dbo].[wZiWeiPaiPan]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		小猫
-- Create date: 2016/4/17
-- Description:	紫薇排盘
-- =============================================
CREATE PROCEDURE [dbo].[wZiWeiPaiPan]
	-- Add the parameters for the stored procedure here
	@MingZhuId int 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @NongLiYue int ,@ShiZhiId int,@NianGanId int,@NongLiRi int ,@MGZhiId int,@SGZhiId int
    select @NongLiYue=NongLiYue,@ShiZhiId=ShiZhiId ,@NianGanId=NianGanId,@NongLiRi=NongLiRi from dmingzhu  where mingzhuid=@MingZhuId

	--定命身宫
	set @MGZhiId = dbo.fZhiOffset(@NongLiYue+2,@ShiZhiId,0) 
	set @SGZhiId = dbo.fZhiOffset(@NongLiYue+2,@ShiZhiId,1)

	--命盘
	exec wZiWeiForDiffType @MingZhuId,1,@MGZhiId,@SGZhiId

	
END

GO
/****** Object:  StoredProcedure [dbo].[wZiWeiPaiPanAll]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[wZiWeiPaiPanAll] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @MingZhuId int
		begin 
		   declare mzs cursor for select MingZhuId  from dMingZhu where Disabled = 0 
		   open mzs --开启游标
		   while @@FETCH_STATUS=0--取值
			 begin
			 fetch next FROM mzs into @MingZhuId--这样就将游标指向下一行，得到的第一行值就传给变量了
			 -------------------------------------------
			      exec [dbo].[wZiWeiPaiPan] @MingZhuId
			 -------------------------------------------
			  end
		   close mzs--关闭游标

		  deallocate  mzs--释放游标
		 end


END

GO
/****** Object:  StoredProcedure [dbo].[zConvertLunarSolar]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[zConvertLunarSolar]
    @iyear int,
	@imon int,
	@iday int,
	@ihour int,
	@imin int,
	@IsleapM bit,
	@ToLunar bit
AS
BEGIN
SET NOCOUNT ON
   begin try
	--固定变量
	DECLARE @msg NVARCHAR(MAX)=ERROR_MESSAGE()

	begin
	--返回值
	declare @solarDt datetime,@leapdays int,@isLeapY bit,@solarY int,@solarM int,@solarD int,@lunarY int,@lunarM int,@lunarD int,@lunarDtStr nvarchar(50)
	declare @curJQ nvarchar(4),@prevJQ nvarchar(4),@prevIQDt datetime,@nextJQ nvarchar(4),@nextJQDt datetime,@JieQiMonth int,@JQMonthFromDt datetime,@JQMonthToDt datetime --节气
	declare @nGan nvarchar(1),@nZhi nvarchar(1),@yGan nvarchar(1),@yZhi nvarchar(1),@rGan nvarchar(1),@rZhi nvarchar(1),@sGan nvarchar(1),@sZhi nvarchar(1) --四柱
	declare @consteName nvarchar(10),@animal nvarchar(2) --星座生肖
	declare @chinaConstellation nvarchar(3) --28星宿
	declare @SolarHoliday nvarchar(100),@LunarHoliday nvarchar(100),@WeekDayHoliday nvarchar(100),@Week nvarchar(3) --节日
	--调用
	--exec zConvertLunarSolar 1995,10,2,8,2,0,1
	--exec zConvertLunarSolar 1995,8,8,8,2,0,0
	--exec zConvertLunarSolar 1995,8,8,8,2,1,0
	---------------------------------------
	declare @MinYear int ,@MaxYear int
	declare @startDt datetime, @gzStartYr datetime,@sartYr int,@chinaConste datetime,@chinaConsteStr nvarchar(200)
	declare @ganStr nvarchar(10),@zhiStr nvarchar(12),@consteStr nvarchar(50), @animalStr nvarchar(12),@WeekStr nvarchar(100)
	set @MinYear = 1900 --1900年为鼠年
	set @MaxYear=2050
	set @startDt = convert(datetime,'1900-01-30')
	set @gzStartYr = convert(datetime,'1899-12-22')
	set @sartYr = 1864 --干支计算起始年
	set @chinaConste=convert(datetime,'2007-9-13')--28星宿参考值,本日为角
	set @chinaConsteStr=N'角木蛟亢金龙女土蝠房日兔心月狐尾火虎箕水豹斗木獬牛金牛氐土貉虚日鼠危月燕室火猪壁水獝奎木狼娄金狗胃土彘昴日鸡毕月乌觜火猴参水猿井木犴鬼金羊柳土獐星日马张月鹿翼火蛇轸水蚓'
    set @ganStr = N'甲乙丙丁戊己庚辛壬癸' 
	set @zhiStr = N'子丑寅卯辰巳午未申酉戌亥'
	set @animalStr = N'鼠牛虎兔龙蛇马羊猴鸡狗猪'
	set @WeekStr=N'星期日星期一星期二星期三星期四星期五星期六'
	set @consteStr=N'白羊座金牛座双子座巨蟹座狮子座处女座天秤座天蝎座射手座摩羯座水瓶座双鱼座'

    ---------------------------------------
	--varidate inpjut
	if @ToLunar = 1 and ( @iyear<@MinYear or @iyear> @MaxYear-1 or @imon<1 or @imon>12 or @iday<1 or @iday>31)
	RAISERROR ('非法公历日期', 16, 1)
	if @ToLunar = 0 and ( @iyear<@MinYear or @iyear> @MaxYear or @imon<1 or @imon>12 or @iday<1 or @iday>30)
	RAISERROR ('非法农历日期', 16, 1)
	if  @ihour<0 or @ihour>24 or @imin<0 or @imin>60
	RAISERROR ('非法时间', 16, 1)
    ---------------------------------------
	end


	--创建农历年表用来保存年月天数,节气表,节日表
	begin
	create table #lunarYear( id int,bitdata binary(3))

	INSERT #lunarYear (id,bitdata) VALUES (1, 0x004BD8)
	INSERT #lunarYear (id,bitdata) VALUES (2, 0x004AE0)
	INSERT #lunarYear (id,bitdata) VALUES (3, 0x00A570)
	INSERT #lunarYear (id,bitdata) VALUES (4, 0x0054D5)
	INSERT #lunarYear (id,bitdata) VALUES (5, 0x00D260)
	INSERT #lunarYear (id,bitdata) VALUES (6, 0x00D950)
	INSERT #lunarYear (id,bitdata) VALUES (7, 0x016554)
	INSERT #lunarYear (id,bitdata) VALUES (8, 0x0056A0)
	INSERT #lunarYear (id,bitdata) VALUES (9, 0x009AD0)
	INSERT #lunarYear (id,bitdata) VALUES (10, 0x0055D2)
	INSERT #lunarYear (id,bitdata) VALUES (11, 0x004AE0)
	INSERT #lunarYear (id,bitdata) VALUES (12, 0x00A5B6)
	INSERT #lunarYear (id,bitdata) VALUES (13, 0x00A4D0)
	INSERT #lunarYear (id,bitdata) VALUES (14, 0x00D250)
	INSERT #lunarYear (id,bitdata) VALUES (15, 0x01D255)
	INSERT #lunarYear (id,bitdata) VALUES (16, 0x00B540)
	INSERT #lunarYear (id,bitdata) VALUES (17, 0x00D6A0)
	INSERT #lunarYear (id,bitdata) VALUES (18, 0x00ADA2)
	INSERT #lunarYear (id,bitdata) VALUES (19, 0x0095B0)
	INSERT #lunarYear (id,bitdata) VALUES (20, 0x014977)
	INSERT #lunarYear (id,bitdata) VALUES (21, 0x004970)
	INSERT #lunarYear (id,bitdata) VALUES (22, 0x00A4B0)
	INSERT #lunarYear (id,bitdata) VALUES (23, 0x00B4B5)
	INSERT #lunarYear (id,bitdata) VALUES (24, 0x006A50)
	INSERT #lunarYear (id,bitdata) VALUES (25, 0x006D40)
	INSERT #lunarYear (id,bitdata) VALUES (26, 0x01AB54)
	INSERT #lunarYear (id,bitdata) VALUES (27, 0x002B60)
	INSERT #lunarYear (id,bitdata) VALUES (28, 0x009570)
	INSERT #lunarYear (id,bitdata) VALUES (29, 0x0052F2)
	INSERT #lunarYear (id,bitdata) VALUES (30, 0x004970)
	INSERT #lunarYear (id,bitdata) VALUES (31, 0x006566)
	INSERT #lunarYear (id,bitdata) VALUES (32, 0x00D4A0)
	INSERT #lunarYear (id,bitdata) VALUES (33, 0x00EA50)
	INSERT #lunarYear (id,bitdata) VALUES (34, 0x006E95)
	INSERT #lunarYear (id,bitdata) VALUES (35, 0x005AD0)
	INSERT #lunarYear (id,bitdata) VALUES (36, 0x002B60)
	INSERT #lunarYear (id,bitdata) VALUES (37, 0x0186E3)
	INSERT #lunarYear (id,bitdata) VALUES (38, 0x0092E0)
	INSERT #lunarYear (id,bitdata) VALUES (39, 0x01C8D7)
	INSERT #lunarYear (id,bitdata) VALUES (40, 0x00C950)
	INSERT #lunarYear (id,bitdata) VALUES (41, 0x00D4A0)
	INSERT #lunarYear (id,bitdata) VALUES (42, 0x01D8A6)
	INSERT #lunarYear (id,bitdata) VALUES (43, 0x00B550)
	INSERT #lunarYear (id,bitdata) VALUES (44, 0x0056A0)
	INSERT #lunarYear (id,bitdata) VALUES (45, 0x01A5B4)
	INSERT #lunarYear (id,bitdata) VALUES (46, 0x0025D0)
	INSERT #lunarYear (id,bitdata) VALUES (47, 0x0092D0)
	INSERT #lunarYear (id,bitdata) VALUES (48, 0x00D2B2)
	INSERT #lunarYear (id,bitdata) VALUES (49, 0x00A950)
	INSERT #lunarYear (id,bitdata) VALUES (50, 0x00B557)
	INSERT #lunarYear (id,bitdata) VALUES (51, 0x006CA0)
	INSERT #lunarYear (id,bitdata) VALUES (52, 0x00B550)
	INSERT #lunarYear (id,bitdata) VALUES (53, 0x015355)
	INSERT #lunarYear (id,bitdata) VALUES (54, 0x004DA0)
	INSERT #lunarYear (id,bitdata) VALUES (55, 0x00A5B0)
	INSERT #lunarYear (id,bitdata) VALUES (56, 0x014573)
	INSERT #lunarYear (id,bitdata) VALUES (57, 0x0052B0)
	INSERT #lunarYear (id,bitdata) VALUES (58, 0x00A9A8)
	INSERT #lunarYear (id,bitdata) VALUES (59, 0x00E950)
	INSERT #lunarYear (id,bitdata) VALUES (60, 0x006AA0)
	INSERT #lunarYear (id,bitdata) VALUES (61, 0x00AEA6)
	INSERT #lunarYear (id,bitdata) VALUES (62, 0x00AB50)
	INSERT #lunarYear (id,bitdata) VALUES (63, 0x004B60)
	INSERT #lunarYear (id,bitdata) VALUES (64, 0x00AAE4)
	INSERT #lunarYear (id,bitdata) VALUES (65, 0x00A570)
	INSERT #lunarYear (id,bitdata) VALUES (66, 0x005260)
	INSERT #lunarYear (id,bitdata) VALUES (67, 0x00F263)
	INSERT #lunarYear (id,bitdata) VALUES (68, 0x00D950)
	INSERT #lunarYear (id,bitdata) VALUES (69, 0x005B57)
	INSERT #lunarYear (id,bitdata) VALUES (70, 0x0056A0)
	INSERT #lunarYear (id,bitdata) VALUES (71, 0x0096D0)
	INSERT #lunarYear (id,bitdata) VALUES (72, 0x004DD5)
	INSERT #lunarYear (id,bitdata) VALUES (73, 0x004AD0)
	INSERT #lunarYear (id,bitdata) VALUES (74, 0x00A4D0)
	INSERT #lunarYear (id,bitdata) VALUES (75, 0x00D4D4)
	INSERT #lunarYear (id,bitdata) VALUES (76, 0x00D250)
	INSERT #lunarYear (id,bitdata) VALUES (77, 0x00D558)
	INSERT #lunarYear (id,bitdata) VALUES (78, 0x00B540)
	INSERT #lunarYear (id,bitdata) VALUES (79, 0x00B6A0)
	INSERT #lunarYear (id,bitdata) VALUES (80, 0x0195A6)
	INSERT #lunarYear (id,bitdata) VALUES (81, 0x0095B0)
	INSERT #lunarYear (id,bitdata) VALUES (82, 0x0049B0)
	INSERT #lunarYear (id,bitdata) VALUES (83, 0x00A974)
	INSERT #lunarYear (id,bitdata) VALUES (84, 0x00A4B0)
	INSERT #lunarYear (id,bitdata) VALUES (85, 0x00B27A)
	INSERT #lunarYear (id,bitdata) VALUES (86, 0x006A50)
	INSERT #lunarYear (id,bitdata) VALUES (87, 0x006D40)
	INSERT #lunarYear (id,bitdata) VALUES (88, 0x00AF46)
	INSERT #lunarYear (id,bitdata) VALUES (89, 0x00AB60)
	INSERT #lunarYear (id,bitdata) VALUES (90, 0x009570)
	INSERT #lunarYear (id,bitdata) VALUES (91, 0x004AF5)
	INSERT #lunarYear (id,bitdata) VALUES (92, 0x004970)
	INSERT #lunarYear (id,bitdata) VALUES (93, 0x0064B0)
	INSERT #lunarYear (id,bitdata) VALUES (94, 0x0074A3)
	INSERT #lunarYear (id,bitdata) VALUES (95, 0x00EA50)
	INSERT #lunarYear (id,bitdata) VALUES (96, 0x006B58)
	INSERT #lunarYear (id,bitdata) VALUES (97, 0x0055C0)
	INSERT #lunarYear (id,bitdata) VALUES (98, 0x00AB60)
	INSERT #lunarYear (id,bitdata) VALUES (99, 0x0096D5)
	INSERT #lunarYear (id,bitdata) VALUES (100, 0x0092E0)
	INSERT #lunarYear (id,bitdata) VALUES (101, 0x00C960)
	INSERT #lunarYear (id,bitdata) VALUES (102, 0x00D954)
	INSERT #lunarYear (id,bitdata) VALUES (103, 0x00D4A0)
	INSERT #lunarYear (id,bitdata) VALUES (104, 0x00DA50)
	INSERT #lunarYear (id,bitdata) VALUES (105, 0x007552)
	INSERT #lunarYear (id,bitdata) VALUES (106, 0x0056A0)
	INSERT #lunarYear (id,bitdata) VALUES (107, 0x00ABB7)
	INSERT #lunarYear (id,bitdata) VALUES (108, 0x0025D0)
	INSERT #lunarYear (id,bitdata) VALUES (109, 0x0092D0)
	INSERT #lunarYear (id,bitdata) VALUES (110, 0x00CAB5)
	INSERT #lunarYear (id,bitdata) VALUES (111, 0x00A950)
	INSERT #lunarYear (id,bitdata) VALUES (112, 0x00B4A0)
	INSERT #lunarYear (id,bitdata) VALUES (113, 0x00BAA4)
	INSERT #lunarYear (id,bitdata) VALUES (114, 0x00AD50)
	INSERT #lunarYear (id,bitdata) VALUES (115, 0x0055D9)
	INSERT #lunarYear (id,bitdata) VALUES (116, 0x004BA0)
	INSERT #lunarYear (id,bitdata) VALUES (117, 0x00A5B0)
	INSERT #lunarYear (id,bitdata) VALUES (118, 0x015176)
	INSERT #lunarYear (id,bitdata) VALUES (119, 0x0052B0)
	INSERT #lunarYear (id,bitdata) VALUES (120, 0x00A930)
	INSERT #lunarYear (id,bitdata) VALUES (121, 0x007954)
	INSERT #lunarYear (id,bitdata) VALUES (122, 0x006AA0)
	INSERT #lunarYear (id,bitdata) VALUES (123, 0x00AD50)
	INSERT #lunarYear (id,bitdata) VALUES (124, 0x005B52)
	INSERT #lunarYear (id,bitdata) VALUES (125, 0x004B60)
	INSERT #lunarYear (id,bitdata) VALUES (126, 0x00A6E6)
	INSERT #lunarYear (id,bitdata) VALUES (127, 0x00A4E0)
	INSERT #lunarYear (id,bitdata) VALUES (128, 0x00D260)
	INSERT #lunarYear (id,bitdata) VALUES (129, 0x00EA65)
	INSERT #lunarYear (id,bitdata) VALUES (130, 0x00D530)
	INSERT #lunarYear (id,bitdata) VALUES (131, 0x005AA0)
	INSERT #lunarYear (id,bitdata) VALUES (132, 0x0076A3)
	INSERT #lunarYear (id,bitdata) VALUES (133, 0x0096D0)
	INSERT #lunarYear (id,bitdata) VALUES (134, 0x004BD7)
	INSERT #lunarYear (id,bitdata) VALUES (135, 0x004AD0)
	INSERT #lunarYear (id,bitdata) VALUES (136, 0x00A4D0)
	INSERT #lunarYear (id,bitdata) VALUES (137, 0x01D0B6)
	INSERT #lunarYear (id,bitdata) VALUES (138, 0x00D250)
	INSERT #lunarYear (id,bitdata) VALUES (139, 0x00D520)
	INSERT #lunarYear (id,bitdata) VALUES (140, 0x00DD45)
	INSERT #lunarYear (id,bitdata) VALUES (141, 0x00B5A0)
	INSERT #lunarYear (id,bitdata) VALUES (142, 0x0056D0)
	INSERT #lunarYear (id,bitdata) VALUES (143, 0x0055B2)
	INSERT #lunarYear (id,bitdata) VALUES (144, 0x0049B0)
	INSERT #lunarYear (id,bitdata) VALUES (145, 0x00A577)
	INSERT #lunarYear (id,bitdata) VALUES (146, 0x00A4B0)
	INSERT #lunarYear (id,bitdata) VALUES (147, 0x00AA50)
	INSERT #lunarYear (id,bitdata) VALUES (148, 0x01B255)
	INSERT #lunarYear (id,bitdata) VALUES (149, 0x006D20)
	INSERT #lunarYear (id,bitdata) VALUES (150, 0x00ADA0)
	INSERT #lunarYear (id,bitdata) VALUES (151, 0x014B63)

    create table #year(
	 yearno int,
	 bitdt binary(3),
	 bitdata int,
	 leapmon int,
	 ydays int,
	 fromdays int,
	 todays int
	)

	create table #ymday(
	 yearno int,
	 monno int,
	 mdays int,
	 leapdays int
	)

	
	CREATE TABLE #JieQi(
	[JieQiId] [int] NOT NULL,
	[JieQiMonth] [int] NOT NULL,
	[JieQi] [varchar](50) NOT NULL,
	[ZhiId] [int] NOT NULL,
	[Minutes] [int] NOT NULL,
	fromDt Datetime)

	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (1, 12, N'小寒', 2, 0)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (2, 12, N'大寒', 2, 21208)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (3, 1, N'立春', 3, 42467)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (4, 1, N'雨水', 3, 63836)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (5, 2, N'惊蛰', 4, 85337)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (6, 2, N'春分', 4, 107014)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (7, 3, N'清明', 5, 128867)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (8, 3, N'谷雨', 5, 150921)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (9, 4, N'立夏', 6, 173149)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (10, 4, N'小满', 6, 195551)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (11, 5, N'芒种', 7, 218072)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (12, 5, N'夏至', 7, 240693)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (13, 6, N'小暑', 8, 263343)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (14, 6, N'大暑', 8, 285989)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (15, 7, N'立秋', 9, 308563)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (16, 7, N'处暑', 9, 331033)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (17, 8, N'白露', 10, 353350)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (18, 8, N'秋分', 10, 375494)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (19, 9, N'寒露', 11, 397447)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (20, 9, N'霜降', 11, 419210)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (21, 10, N'立冬', 12, 440795)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (22, 10, N'小雪', 12, 462224)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (23, 11, N'大雪', 1, 483532)
	INSERT #JieQi ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (24, 11, N'冬至', 1, 504758)

	create table #JieRi(
	jieriid int,
	jrtype int,  -- 1:公历节日　2:农历节日 3:按第几个星期算的节日
	hmon int,
	hday int,
	recess int,
	holiday nvarchar(50)
	)

	INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (1, 1, 1, 1, 1, N'元旦')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (2, 1, 2, 2, 0, N'世界湿地日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (3, 1, 2, 10, 0, N'国际气象节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (4, 1, 2, 14, 0, N'情人节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (5, 1, 3, 1, 0, N'国际海豹日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (6, 1, 3, 5, 0, N'学雷锋纪念日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (7, 1, 3, 8, 0, N'妇女节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (8, 1, 3, 12, 0, N'植树节 孙中山逝世纪念日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (9, 1, 3, 14, 0, N'国际警察日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (10, 1, 3, 15, 0, N'消费者权益日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (11, 1, 3, 17, 0, N'中国国医节 国际航海日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (12, 1, 3, 21, 0, N'世界森林日 消除种族歧视国际日 世界儿歌日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (13, 1, 3, 22, 0, N'世界水日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (14, 1, 3, 24, 0, N'世界防治结核病日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (15, 1, 4, 1, 0, N'愚人节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (16, 1, 4, 7, 0, N'世界卫生日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (17, 1, 4, 22, 0, N'世界地球日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (18, 1, 5, 1, 1, N'劳动节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (19, 1, 5, 2, 1, N'劳动节假日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (20, 1, 5, 3, 1, N'劳动节假日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (21, 1, 5, 4, 0, N'青年节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (22, 1, 5, 8, 0, N'世界红十字日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (23, 1, 5, 12, 0, N'国际护士节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (24, 1, 5, 31, 0, N'世界无烟日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (25, 1, 6, 1, 0, N'国际儿童节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (26, 1, 6, 5, 0, N'世界环境保护日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (27, 1, 6, 26, 0, N'国际禁毒日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (28, 1, 7, 1, 0, N'建党节 香港回归纪念 世界建筑日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (29, 1, 7, 11, 0, N'世界人口日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (30, 1, 8, 1, 0, N'建军节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (31, 1, 8, 8, 0, N'中国男子节 父亲节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (32, 1, 8, 15, 0, N'抗日战争胜利纪念')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (33, 1, 9, 9, 0, N'  逝世纪念')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (34, 1, 9, 10, 0, N'教师节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (35, 1, 9, 18, 0, N'九·一八事变纪念日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (36, 1, 9, 20, 0, N'国际爱牙日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (37, 1, 9, 27, 0, N'世界旅游日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (38, 1, 9, 28, 0, N'孔子诞辰')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (39, 1, 10, 1, 1, N'国庆节 国际音乐日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (40, 1, 10, 2, 1, N'国庆节假日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (41, 1, 10, 3, 1, N'国庆节假日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (42, 1, 10, 6, 0, N'老人节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (43, 1, 10, 24, 0, N'联合国日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (44, 1, 11, 10, 0, N'世界青年节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (45, 1, 11, 12, 0, N'孙中山诞辰纪念')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (46, 1, 12, 1, 0, N'世界艾滋病日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (47, 1, 12, 3, 0, N'世界残疾人日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (48, 1, 12, 20, 0, N'澳门回归纪念')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (49, 1, 12, 24, 0, N'平安夜')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (50, 1, 12, 25, 0, N'圣诞节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (51, 1, 12, 26, 0, N' 诞辰纪念')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (52, 2, 1, 1, 1, N'春节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (53, 2, 1, 15, 0, N'元宵节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (54, 2, 5, 5, 0, N'端午节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (55, 2, 7, 7, 0, N'七夕情人节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (56, 2, 7, 15, 0, N'中元节 盂兰盆节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (57, 2, 8, 15, 0, N'中秋节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (58, 2, 9, 9, 0, N'重阳节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (59, 2, 12, 8, 0, N'腊八节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (60, 2, 12, 23, 0, N'北方小年(扫房)')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (61, 2, 12, 24, 0, N'南方小年(掸尘)')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (62, 3, 5, 2, 1, N'母亲节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (63, 3, 5, 3, 1, N'全国助残日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (64, 3, 6, 3, 1, N'父亲节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (65, 3, 9, 3, 3, N'国际和平日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (66, 3, 9, 4, 1, N'国际聋人节')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (67, 3, 10, 1, 2, N'国际住房日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (68, 3, 10, 1, 4, N'国际减轻自然灾害日')
INSERT #JieRi ([jieriid], [jrtype], [hmon], [hday], [recess], [holiday]) VALUES (69, 3, 11, 4, 5, N'感恩节')

	end

	--生成年月天数
	begin
	insert into #year(yearNo,bitdt,bitData)
	select id+1899,bitdata,bitdata from #lunarYear

	update #year set leapmon=bitData & 0xF

	insert into #ymday(yearno,monno)
	select yearno,1 from #year
	union
	select yearno,2 from #year
	union
	select yearno,3 from #year
	union
	select yearno,4 from #year
	union
	select yearno,5 from #year
	union
	select yearno,6 from #year
	union
	select yearno,7 from #year
	union
	select yearno,8 from #year
	union
	select yearno,9 from #year
	union
	select yearno,10 from #year
	union
	select yearno,11 from #year
	union
	select yearno,12 from #year

	update #ymday set mdays = dbo.fGetMonthDays(y.bitdata,#ymday.monno,0) from #year y where y.yearNo = #ymday.yearno 
	update #ymday set leapdays = dbo.fGetMonthDays(y.bitdata,y.leapmon,1) from #year y where y.yearNo = #ymday.yearno and y.leapmon=#ymday.monno
	update #year set ydays=(select  sum(ym.mdays)+sum(isnull(ym.leapdays,0)) from #ymday ym where ym.yearno=#year.yearno)
	update #year set fromdays=(select sum(y1.ydays) from #year y1 where y1.yearno<#year.yearno),todays=(select sum(y2.ydays) from #year y2 where y2.yearno<#year.yearno+1)
	end

	--select * from #year
	--农历阴历转换
	declare  @dayDiff int,@fromdays int,@mdays int
	declare @lunarYStr nvarchar(10),@lunarMStr nvarchar(10),@lunarDStr nvarchar(10)
	begin
	if @ToLunar = 1
	begin
	    -- 公历转换成阴历
		set @solarY = @iyear
		set @solarM=@imon
		set @solarD=@iday
		set @solarDt = convert(datetime,convert(varchar(4),@solarY)+'-'+convert(varchar(2),@solarM)+'-'+convert(varchar(2),@solarD)+' '+convert(varchar(2),@ihour)+':'+convert(varchar(2),@imin)+':00',20)	
		if @solarDt<'1900-01-30' or @solarDt>'2049-12-31'  RAISERROR ('超出可转换的日期', 16, 1)
		set @dayDiff = datediff(d,@startDt,@solarDt)
		select @lunarY=y.yearno,@isLeapY =(case leapmon when 0 then 0 else 1 end),@fromdays=fromdays  from #year y where @dayDiff between fromdays and todays
		set @dayDiff = @dayDiff - @fromdays
		
		select @lunarM=ym.monno,@dayDiff=@dayDiff-(select sum(ym1.mdays)+sum(isnull(ym1.leapdays,0)) from #ymday ym1 where ym1.yearno= ym.yearno and ym1.monno<ym.monno)
		,@mdays=mdays,@leapdays=leapdays
		 from #ymday ym where ym.yearno=@lunarY and @dayDiff between (select sum(ym1.mdays)+sum(isnull(ym1.leapdays,0)) from #ymday ym1 where ym1.yearno= ym.yearno and ym1.monno<ym.monno) and 
		(select sum(ym2.mdays)+sum(isnull(ym2.leapdays,0)) from #ymday ym2 where ym2.yearno= ym.yearno and ym2.monno<ym.monno+1)
		if @dayDiff>@mdays 
		begin
			set @lunarD = @dayDiff - @mdays
			set @isLeapM = 1
		end 
		else 
		begin
			set @lunarD = @dayDiff 
			set @isLeapM = 0
		end
    end
	else 	
	begin
	　　-- 阴历转换成公历
	    set @lunarY = @iyear
		set @lunarM=@imon
		set @lunarD=@iday 
		declare @leapmon int
		select @dayDiff = fromdays,@isLeapY =(case leapmon when 0 then 0 else 1 end),@leapmon=leapmon from #year where yearno=@lunarY
		if @IsleapM = 1 and @lunarM <> @leapmon 
		begin 
		  set @IsleapM = 0
		   --RAISERROR ('非法农历日期', 16, 1)
		end
		select @dayDiff=@dayDiff+(select sum(ym1.mdays)+sum(isnull(ym1.leapdays,0)) from #ymday ym1 where ym1.yearno=ym.yearno and ym1.monno<ym.monno)+(case @IsleapM when 1 then mdays else 0 end)+@lunarD  
		from #ymday ym  where ym.yearno=@lunarY and ym.monno=@lunarM
		set @solarDt = dateadd(day,@dayDiff,@startDt)
		set @solarY = datepart(year,@solarDt)
		set @solarM=datepart(month,@solarDt)
		set @solarD=datepart(day,@solarDt)
	end
	
	set @lunarYStr = dbo.fConvertLunarDtStr(@lunarY/1000,1)+dbo.fConvertLunarDtStr((@lunarY%1000)/100,1)+dbo.fConvertLunarDtStr((@lunarY%100)/10,1)+dbo.fConvertLunarDtStr(@lunarY%10,1)
	set @lunarMStr = dbo.fConvertLunarDtStr(@lunarM,2)
	set @lunarDStr = dbo.fConvertLunarDtStr(@lunarD,3)
	set @lunarDtStr= '农历' + @lunarYStr + '年'+ (case @isLeapM when 1 then '闰' else '' end)+ @lunarMStr +'月'+ @lunarDStr+'日'
	end

	--四柱干支
	begin
	declare @tmpGan nvarchar(12),@indexGan int , @i int,@tHour int,@tMin int,@offset int

	--年干支
	set @i=(@lunarY-@sartYr)%60
	set @nGan = substring(@ganStr,@i%10+1,1)
	set @nZhi = substring(@zhiStr,@i%12+1,1)
	--月干支
	declare @jieQiStartDt datetime,@JieQiId int
	set @jieQiStartDt = convert(datetime,'1900-01-06 02:05:00',20)	
	update #JieQi set fromDt = dateadd(minute,525948.76 * (@solarY - 1900) + Minutes,@jieQiStartDt)
	select @curJQ=JieQi,@JieQiId=JieQiId,@JieQiMonth=JieQiMonth,@yZhi=substring(@zhiStr,ZhiId,1),@prevIQDt = fromDt
	  from #JieQi jq where @solarDt between fromDt and 
		(select fromDt from #JieQi jq2 where jq2.JieQiId = jq.JieQiId+1)	
	select @prevJQ=JieQi from #JieQi jq where jq.JieQiId=(case @JieQiId when 1 then 24 else @JieQiId-1 end)
	select @nextJQ=JieQi,@nextJQDt = fromDt from #JieQi jq where jq.JieQiId=(case @JieQiId when 24 then 1 else @JieQiId+1 end)
	select @JQMonthFromDt=fromDt from #JieQi jq where JieQiMonth = @JieQiMonth and JieQiId%2=1
	select @JQMonthToDt=fromDt from #JieQi jq where JieQiMonth = @JieQiMonth+1 and JieQiId%2=1
	--按照节气定月干支
	set @i = @i%10
	select @yGan =substring(@ganStr,((case @i when 0 then 3 when 1 then 5 when 2 then 7 when 3 then 9 when 4 then 1 
	when 5 then 3 when 6 then 5 when 7 then 7 when 8 then 9  when 9 then 1 end)+@JieQiMonth-2)%10+1,1)
	
	--日干支
	set @dayDiff = datediff(d,@gzStartYr,@solarDt)
	set @i = @dayDiff%60 
	set @rGan = substring(@ganStr,@i%10+1,1)
	set @rZhi = substring(@zhiStr,@i%12+1,1)
	--时干支
	set @tHour = @ihour 
	set @tMin = @imin
	set @i = @i%10
	if @imin != 0 set @tHour += 1
	set @offset = @tHour/2 
	if @offset >=12 set @offset=0
	select @sGan =substring(@ganStr,((case @i when 0 then 1 when 1 then 3 when 2 then 5 when 3 then 7 when 4 then 9 
	when 5 then 1 when 6 then 3 when 7 then 5 when 8 then 7  when 9 then 9 end)+@offset-1)%10+1,1)
	--set @indexGan = ((@i % 10 + 1) * 2 -1) % 10  ; --ganStr[i % 10] 为日的天干,(n*2-1) %10得出地支对应,n从1开始
	--set @tmpGan = substring(@ganStr,@indexGan,10-@indexGan)+substring(@ganStr,0,@indexGan+2)  -- 凑齐12位
	--set @sGan = substring(@tmpGan,@offset+1,1)
	set @sZhi = substring(@zhiStr,@offset+1,1)
	end

	--星座
	  set @i=@solarM *100 + @solarD
	  if (((@i >= 321) and (@i <= 419))) set @offset=0
	  else if ((@i >= 420) and (@i <= 520)) set @offset=1
	  else if ((@i >= 521) and (@i <= 620)) set @offset=2
	  else if ((@i >= 621) and (@i <= 722)) set @offset=3
	  else if ((@i= 823) and (@i <= 922)) set @offset=4
	  else if ((@i= 823) and (@i <= 922)) set @offset=5
	  else if ((@i >= 923) and (@i <= 1022)) set @offset=6
	  else if ((@i >= 1023) and (@i <= 1121)) set @offset=7
	  else if ((@i >= 1122) and (@i <= 1221)) set @offset=8
	  else if ((@i >= 1222) or (@i <= 119)) set @offset=9
	  else if ((@i >= 120) and (@i <= 218)) set @offset=10
	  else if ((@i >= 219) and (@i <= 320)) set @offset=11
	  set @consteName= substring(@consteStr,@offset*3+1,3)
	  --属相 
	  set @animal = substring(@animalStr,(@solarY-@MinYear)%12+1,1)

	  --28星宿计算
	  set @i = datediff(d,@chinaConste,@solarDt)%28
	  if @i >= 0 set @chinaConstellation = substring(@chinaConsteStr,@i*3+1,3)
	  else set @chinaConstellation = substring(@chinaConsteStr,(27+@i)*3+1,3)

	  --节日  
	  declare @wOfMon int,@firstMonthDay datetime
	  select @SolarHoliday=holiday from #JieRi where jrtype=1 and hmon=@SolarM and hday=@SolarD
	  if @IsLeapM = 0
	  select @SolarHoliday=holiday from #JieRi where jrtype=2 and hmon=@LunarM and hday=@LunarD
	  if @LunarM = 12 --除夕
	  begin
	   declare @Bitdata int,@WeekOfMonth int,@dayOfWeek int
	   select @Bitdata=bitdata from #year where yearno=@LunarY
	   set @i=dbo.fGetMonthDays(@Bitdata,12,0)
	   if @LunarD = @i set @SolarHoliday=N'除夕'
	  end
	  set @dayOfWeek = datepart(dw, @SolarDt)
	  set @Week = substring(@WeekStr,(@dayOfWeek-1)*3+1,3)
	  set @firstMonthDay = dateadd(day,1-@SolarD,@SolarDt)
	  set @WeekOfMonth = datepart(week,@SolarDt)-datepart(week,dateadd(day,1-@SolarD,@SolarDt))+1 
	  set @i = datepart(dw, @firstMonthDay)
	  select @WeekDayHoliday=holiday from #JieRi where jrtype=3 and hmon=@SolarM  and recess=@dayOfWeek
	  and ((@i>=@dayOfWeek and hday = @WeekOfMonth-1) or (@i<@dayOfWeek and hday = @WeekOfMonth))
	  ----------------------
    select @solarDt  as solarDt,@solarY as solarY,@solarM as solarM,@solarD as solarD
	,@lunarDtStr as lunarDtStr,@lunarY as lunarY,@lunarM  as lunarM,@lunarD  as lunarD,@isLeapY as isLeapY,@isLeapM as isLeapM
	,@curJQ as curJQ,@prevJQ as prevJQ ,@prevIQDt as prevIQDt ,@nextJQ as nextJQ,@nextJQDt as nextJQDt,@JQMonthFromDt as JQMonthFromDt ,@JQMonthToDt as JQMonthToDt
	,@nGan as nGan,@nZhi as nZhi,@yGan as yGan,@yZhi as yZhi,@rGan as rGan,@rZhi as rZhi,@sGan as sGan,@sZhi as sZhi --四柱
	,@consteName as consteName,@animal as  animal,@chinaConstellation as chinaConstellation --28星宿
	,@SolarHoliday as SolarHoliday,@LunarHoliday as LunarHoliday,@WeekDayHoliday as WeekDayHoliday,@Week  as Week--节日
  
  drop table #lunarYear
  drop table #year
  drop table #ymday
  drop table #JieQi
  drop table #JieRi
  end try
  begin catch 
      SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
  end catch
END
GO
/****** Object:  UserDefinedFunction [dbo].[fBitShift]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/4/27
-- Description:	bit left shift or right shift
-- =============================================
CREATE FUNCTION [dbo].[fBitShift]
(
	@i int = 1 ,-- integer
	@n int,  -- shift
	@left bit -- if left shift
)
RETURNS int
AS
BEGIN
	 declare @m int,@s int
	 if @left = 0 
	 select  @n%=32,@m=power(2,31-@n),@s=@i&@m,@i&=@m-1,@i*=power(2.,@n)
	 else 
	 select  @n%=32,@m=power(2,31-@n),@s=@i&@m,@i&=@m-1,@i/=power(2.,@n)
	 if(@s>0)set @i|=0x80000000
	 return @i -- -1382285312
END

GO
/****** Object:  UserDefinedFunction [dbo].[fConvertLunarDtStr]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		xiaomao
-- Create date: 2016/4/28
-- Description:	转换成农历日期表示法如
--				农历一九九七年正月初五
-- =============================================
CREATE FUNCTION [dbo].[fConvertLunarDtStr] 
(
	@n int,
	@type int -- 1:year 2:month 3:day
)
RETURNS nvarchar(10)
AS
BEGIN
  declare @lStr nvarchar(10),@HZNum  nvarchar(10),@nStr1 nvarchar(10),@nStr2 nvarchar(4),@nStr3 nvarchar(13)
  set @HZNum = '零一二三四五六七八九'
  set @nStr1 = N'日一二三四五六七八九'
  set @nStr2 = N'初十廿卅'

  if @type =1 and (@n <1 or @n >9) set @lStr=''
  else if @type =2 and (@n <1 or @n >13) set @lStr=''
  else if @type =3 and (@n <1 or @n >30) set @lStr=''
  else if @type =3
	  begin
	   if @n = 10 set @lStr='初十'
	   else if @n = 20 set @lStr='二十'
	   else if @n = 30 set @lStr='三十'
	   else set @lStr=substring(@nStr2,@n/10+1,1)+substring(@nStr1,@n%10+1,1)
	  end
  else 
  begin
     if (@n <10) set @lStr=substring(@HZNum,@n+1,1)
	 if @type =2 and @n = 1 set @lStr='正'
	 if @n = 10 set @lStr='十'
	 if @n = 11 set @lStr='十一'
	 if @n = 12 set @lStr='腊'
  end
  return @lStr

END

GO
/****** Object:  UserDefinedFunction [dbo].[fGanOffset]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/5/2
-- Description:	干向前或向后移动n位
-- =============================================
Create FUNCTION [dbo].[fGanOffset]
(
	@FromId int,
	@Offset int,
	@IsShun bit
)
RETURNS int 
AS
BEGIN
	declare @ToGanId int
	if @IsShun = 1 
	begin
		set @ToGanId=(@FromId+@Offset-1)%10
		if(@ToGanId < 0) begin set @ToGanId += 10 end
		if(@ToGanId = 0) begin set @ToGanId = 10 end
	end 
	if @IsShun = 0
	begin
		set @ToGanId=(@FromId-@Offset+1)%10
		if(@ToGanId < 0) begin set @ToGanId += 10 end
		if(@ToGanId = 0) begin set @ToGanId = 10 end
	end 
	RETURN @ToGanId

END

GO
/****** Object:  UserDefinedFunction [dbo].[fGetMonthDays]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fGetMonthDays]  
(
	@bitData int,
    @month int,
	@leap bit
)
RETURNS int
AS
BEGIN
    declare @t1 int,@t2 int,@t3 binary(3),@t4 int
	if @leap = 0 
	   begin 
			set @t1 = @bitData & 0x0000FFFF

			set @t2 = 16 - @month
			set @t3 = dbo.fBitShift(1,@t2,0)
			if @t1 & @t3 = 0
			 set @t4 = 29
			else 
			 set @t4 = 30
		end 
	 else 
	    begin
			if @bitData & 0x10000 = 0
			 set @t4 = 29
			else 
			 set @t4 = 30
			  
		end

	 return @t4
END
GO
/****** Object:  UserDefinedFunction [dbo].[fZhiOffset]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		xiaomao
-- Create date: 2016/5/2
-- Description:	支向前或向后移动n位
-- =============================================
CREATE FUNCTION [dbo].[fZhiOffset]
(
	@FromZhiId int,
	@OffsetZhiId int,
	@IsShun bit
)
RETURNS int 
AS
BEGIN
	-- Declare the return variable here
	declare @ToZhiId int
	if @IsShun = 1 
	begin
		set @ToZhiId=(@FromZhiId+@OffsetZhiId-1)%12
		if(@ToZhiId < 0) begin set @ToZhiId += 12 end
		if(@ToZhiId = 0) begin set @ToZhiId = 12 end
	end 
	if @IsShun = 0
	begin
		set @ToZhiId=(@FromZhiId-@OffsetZhiId+1)%12
		if(@ToZhiId < 0) begin set @ToZhiId += 12 end
		if(@ToZhiId = 0) begin set @ToZhiId = 12 end
	end 
	RETURN @ToZhiId

END

GO
/****** Object:  Table [dbo].[dBaZi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dBaZi](
	[BaZiId] [int] IDENTITY(1,1) NOT NULL,
	[MingZhuId] [int] NOT NULL,
	[GanZhiTypeId] [int] NOT NULL,
	[Year] [int] NULL,
	[GanId] [int] NULL,
	[ZhiId] [int] NULL,
	[ZhiCGanId1] [int] NULL,
	[ZhiCGanId2] [int] NULL,
	[ZhiCGanId3] [int] NULL,
	[GanSSId] [int] NULL,
	[ZhiSSId1] [int] NULL,
	[ZhiSSId2] [int] NULL,
	[ZhiSSId3] [int] NULL,
	[WangShuaiId] [int] NULL,
	[NaYinId] [int] NULL,
	[BaZiSeq] [int] NULL,
	[BaZiRefId] [int] NULL,
 CONSTRAINT [PK_dBaZi] PRIMARY KEY CLUSTERED 
(
	[BaZiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dMingZhu]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[dMingZhu](
	[MingZhuId] [int] IDENTITY(1,1) NOT NULL,
	[Disabled] [bit] NOT NULL,
	[MingZhu] [nvarchar](50) NULL,
	[XingBie] [varchar](2) NULL,
	[GongLi] [datetime] NULL,
	[NongLi] [nvarchar](50) NULL,
	[GongLiNian] [int] NULL,
	[GongLiYue] [int] NULL,
	[GongLiRi] [int] NULL,
	[Shi] [int] NULL,
	[Feng] [int] NULL,
	[NongLiNian] [int] NULL,
	[NongLiYue] [int] NULL,
	[NongLiRi] [int] NULL,
	[NianGanId] [int] NULL,
	[NianZhiId] [int] NULL,
	[YueGanId] [int] NULL,
	[YueZhiId] [int] NULL,
	[RiGanId] [int] NULL,
	[RiZhiId] [int] NULL,
	[ShiGanId] [int] NULL,
	[ShiZhiId] [int] NULL,
	[CurrentJieQiId] [int] NULL,
	[PreviousJieQiId] [int] NULL,
	[PreviousJieQiDate] [datetime] NULL,
	[NextJieQiId] [int] NULL,
	[NextJieQiDate] [datetime] NULL,
	[IsShun] [bit] NOT NULL,
	[Note] [nvarchar](200) NULL,
	[CreateBy] [nvarchar](50) NOT NULL,
	[CreateDateTime] [datetime] NOT NULL,
	[LastModifyBy] [nvarchar](50) NOT NULL,
	[LastModifyDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dMingZhu] PRIMARY KEY CLUSTERED 
(
	[MingZhuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[dMingZhuAdd]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dMingZhuAdd](
	[MingZhuId] [int] NOT NULL,
	[JQMonthFromDt] [datetime] NULL,
	[JQMonthToDt] [datetime] NULL,
	[QiYunDateTime] [datetime] NULL,
	[QiYunSui] [int] NULL,
	[KongWangZhiId1] [int] NULL,
	[KongWangZhiId2] [int] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dMingZhuGZGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dMingZhuGZGX](
	[MingZhuId] [int] NOT NULL,
	[MingZhu] [nvarchar](50) NULL,
	[GanZhiType1] [nvarchar](10) NULL,
	[GanZhiType2] [nvarchar](10) NULL,
	[GanZhiType3] [nvarchar](10) NULL,
	[GanZhiGXType] [nvarchar](50) NULL,
	[DYPeriod] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[GanZhiTypeId1] [int] NULL,
	[Gan1] [nvarchar](1) NULL,
	[Zhi1] [nvarchar](1) NULL,
	[GanZhiTypeId2] [int] NULL,
	[Gan2] [nvarchar](1) NULL,
	[Zhi2] [nvarchar](1) NULL,
	[GanZhiTypeId3] [int] NULL,
	[Gan3] [nvarchar](1) NULL,
	[Zhi3] [nvarchar](1) NULL,
	[Remark] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dMingZhuSS]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dMingZhuSS](
	[MingZhuId] [int] NOT NULL,
	[ShengShaId] [int] NOT NULL,
	[GanZhiTypeId] [int] NOT NULL,
	[Remark] [nvarchar](50) NULL,
	[CreateDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_dMingZhuSS] PRIMARY KEY CLUSTERED 
(
	[MingZhuId] ASC,
	[ShengShaId] ASC,
	[GanZhiTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dMingZhuZWAdd]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dMingZhuZWAdd](
	[MingZhuId] [int] NOT NULL,
	[WuHangId] [int] NOT NULL,
	[YueGanId] [int] NOT NULL,
	[YueZhiId] [int] NOT NULL,
 CONSTRAINT [PK_dMingZhuZWAdd] PRIMARY KEY CLUSTERED 
(
	[MingZhuId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dZiWei]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dZiWei](
	[ZiWeiId] [bigint] IDENTITY(1,1) NOT NULL,
	[MingZhuId] [int] NOT NULL,
	[PaiPanTypeId] [int] NOT NULL,
	[GongWeiId] [int] NOT NULL,
	[IsShengGong] [bit] NOT NULL,
	[GanId] [int] NOT NULL,
	[ZhiId] [int] NOT NULL,
	[HuaLuXYId] [int] NULL,
	[HuaLuGWId] [int] NULL,
	[HuaQuanXYId] [int] NULL,
	[HuaQuanGWId] [int] NULL,
	[HuaKeXYId] [int] NULL,
	[HuaKeGWId] [int] NULL,
	[HuaJiXYId] [int] NULL,
	[HuaJiGWId] [int] NULL,
	[DaXianFrom] [int] NULL,
	[DaXianTo] [int] NULL,
 CONSTRAINT [PK_dZiWei] PRIMARY KEY CLUSTERED 
(
	[ZiWeiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[dZiWeiXingYao]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dZiWeiXingYao](
	[ZiWeiId] [bigint] NOT NULL,
	[XingYaoId] [int] NOT NULL,
	[MiaoXianId] [int] NULL,
 CONSTRAINT [PK_dZiWeiXingYao] PRIMARY KEY CLUSTERED 
(
	[ZiWeiId] ASC,
	[XingYaoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wFeiXing]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wFeiXing](
	[FeiXingTypeId] [int] NOT NULL,
	[FeiXing] [nvarchar](200) NOT NULL,
	[FromGongWeiID] [int] NULL,
	[ToGongWeiID] [int] NULL,
	[Note] [ntext] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wGanSiHua]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wGanSiHua](
	[GanSiHuaId] [int] NOT NULL,
	[GanId] [int] NOT NULL,
	[SiHuaId] [int] NOT NULL,
	[XingYaoId] [int] NOT NULL,
 CONSTRAINT [PK_wGanSiHua] PRIMARY KEY CLUSTERED 
(
	[GanSiHuaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wMiaoXian]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wMiaoXian](
	[MiaoXianId] [int] NOT NULL,
	[MiaoXian] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_wMiaoXian] PRIMARY KEY CLUSTERED 
(
	[MiaoXianId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wMiaoXianGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wMiaoXianGX](
	[XingYaoId] [int] NOT NULL,
	[ZhiId] [int] NOT NULL,
	[MiaoXianId] [int] NOT NULL,
 CONSTRAINT [PK_wMiaoXianGX] PRIMARY KEY CLUSTERED 
(
	[XingYaoId] ASC,
	[ZhiId] ASC,
	[MiaoXianId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wSiHua]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wSiHua](
	[SiHuaId] [int] NOT NULL,
	[SiHua] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_wSiHua] PRIMARY KEY CLUSTERED 
(
	[SiHuaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[wXingYao]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[wXingYao](
	[XingYaoId] [int] NOT NULL,
	[XingYaoTypeId] [int] NOT NULL,
	[XingYao] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_wXingYao] PRIMARY KEY CLUSTERED 
(
	[XingYaoId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[zGan]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[zGan](
	[GanId] [int] NOT NULL,
	[Gan] [varchar](2) NOT NULL,
	[YingYangId] [int] NOT NULL,
	[WuHangId] [int] NOT NULL,
	[JiJieId] [int] NULL,
	[FangWeiId] [int] NULL,
	[TiBiaoId] [int] NULL,
	[ZangFuId] [int] NULL,
 CONSTRAINT [PK_zGan] PRIMARY KEY CLUSTERED 
(
	[GanId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[zGanZhiGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zGanZhiGX](
	[GXId] [int] IDENTITY(1,1) NOT NULL,
	[GXTypeId] [int] NULL,
	[GanZhiId1] [int] NOT NULL,
	[GanZhiId2] [int] NOT NULL,
	[GanZhiId3] [int] NULL,
	[GanZhiGXId] [int] NULL,
	[GXValueId] [int] NULL,
	[Remark] [nvarchar](50) NULL,
 CONSTRAINT [PK_zZhiGX] PRIMARY KEY CLUSTERED 
(
	[GXId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[zJiaZi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zJiaZi](
	[JiaZiId] [int] NOT NULL,
	[jiaZiGanId] [int] NOT NULL,
	[JiaZiZhiId] [int] NOT NULL,
	[NaYinId] [int] NULL,
 CONSTRAINT [PK_zJiaZi] PRIMARY KEY CLUSTERED 
(
	[JiaZiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[zJieQi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[zJieQi](
	[JieQiId] [int] NOT NULL,
	[JieQiMonth] [int] NOT NULL,
	[JieQi] [varchar](50) NOT NULL,
	[ZhiId] [int] NOT NULL,
	[Minutes] [int] NOT NULL,
 CONSTRAINT [PK_zJieQi] PRIMARY KEY CLUSTERED 
(
	[JieQiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[zSetting]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[zSetting](
	[SKey] [varchar](20) NOT NULL,
	[SKeyId] [int] NULL,
	[SValue] [nvarchar](50) NOT NULL,
	[Disabled] [bit] NOT NULL,
	[GanId1] [int] NULL,
	[GanId2] [int] NULL,
	[GanId3] [int] NULL,
	[GanId4] [int] NULL,
	[ZhiId1] [int] NULL,
	[ZhiId2] [int] NULL,
	[ZhiId3] [int] NULL,
	[ZhiId4] [int] NULL,
	[TypeId] [int] NULL,
	[XingYaoId] [int] NULL,
	[ShunNi] [bit] NULL,
	[SNote] [nvarchar](200) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[zSuanMing]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[zSuanMing](
	[SKey] [varchar](20) NOT NULL,
	[SKeyId] [int] NOT NULL,
	[SValue] [nvarchar](50) NOT NULL,
	[SAlias] [nvarchar](50) NULL,
	[SDisabled] [bit] NOT NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[zWuHang]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[zWuHang](
	[WuHangId] [int] IDENTITY(1,1) NOT NULL,
	[WuHang] [varchar](2) NOT NULL,
	[WuHangJu] [nvarchar](10) NOT NULL,
	[JuShu] [int] NOT NULL,
	[QiZhiId] [int] NOT NULL,
 CONSTRAINT [PK_zWuHang] PRIMARY KEY CLUSTERED 
(
	[WuHangId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[zWuHangGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[zWuHangGX](
	[WuHangGXId] [int] NOT NULL,
	[ZhuTiId] [int] NOT NULL,
	[ShengKeId] [int] NOT NULL,
	[KeTiId] [int] NOT NULL,
 CONSTRAINT [PK_zWuHangGX] PRIMARY KEY CLUSTERED 
(
	[WuHangGXId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[zZhi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[zZhi](
	[ZhiId] [int] NOT NULL,
	[Zhi] [varchar](2) NOT NULL,
	[YingYangId] [int] NOT NULL,
	[WuhangId] [int] NOT NULL,
	[FromShi] [int] NOT NULL,
	[ToShi] [int] NOT NULL,
	[ShengXiaoId] [int] NOT NULL,
	[CangGanId1] [int] NOT NULL,
	[CangGanId2] [int] NULL,
	[CangGanId3] [int] NULL,
	[JiJieId] [int] NOT NULL,
	[FangWeiId] [int] NOT NULL,
 CONSTRAINT [PK_zZhi] PRIMARY KEY CLUSTERED 
(
	[ZhiId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  View [dbo].[vZiWeiXY]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vZiWeiXY]
AS
SELECT  TOP (100) PERCENT zw.ZiWeiId, zw.MingZhuId, zw.PaiPanTypeId, zw.GongWeiId, xy.XingYao, xy.XingYaoId, 
                   xy.XingYaoTypeId, xyt.SValue AS XingYaoType
FROM      dbo.dZiWei AS zw LEFT OUTER JOIN
                   dbo.dZiWeiXingYao AS zwxy ON zw.ZiWeiId = zwxy.ZiWeiId LEFT OUTER JOIN
                   dbo.wXingYao AS xy ON zwxy.XingYaoId = xy.XingYaoId LEFT OUTER JOIN
                   dbo.zSuanMing AS xyt ON xy.XingYaoTypeId = xyt.SKeyId AND xyt.SKey = 'zwXingYaoType' AND xyt.SDisabled = 0
ORDER BY zw.GanId, xy.XingYaoTypeId, xy.XingYaoId

GO
/****** Object:  View [dbo].[vZiWeiGW]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*ORDER BY zw.GongWeiId, xy.XingYaoTypeId, xy.XingYaoId*/
CREATE VIEW [dbo].[vZiWeiGW]
AS
select zwt.mingzhuid,zwt.mingzhu,zwt.xingbie,zwt.gongli,zwt.nongli,zwt.gongwei,case zwt.isshenggong when 1 then N'身宫' else '' end as ShengGong, zwt.gan,zwt.zhi,isnull(substring(zwt.zhengyaos,1,len(zwt.zhengyaos)-1),'') as zhengyaos
 ,isnull(substring(zwt.fuyaos,1,len(zwt.fuyaos)-1),'') as fuyaos,isnull(substring(zwt.zayaos,1,len(zwt.zayaos)-1),'') as zayaos,isnull(substring(zwt.changshengyaos,1,len(zwt.changshengyaos)-1),'') as changshengyaos
,isnull(substring(zwt.taisuiyaos,1,len(zwt.taisuiyaos)-1),'') as taisuiyaos,zwt.HLXY,zwt.HLGW,zwt.HQXY,zwt.HQGW,zwt.HKXY,zwt.HKGW,zwt.HJXY,zwt.HJGW,zwt.ziweiid,zwt.paipantypeid,zwt.gongweiid
,zwt.isshenggong,zwt.ganid,zwt.zhiid,zwt.hualuxyid,zwt.hualugwid,zwt.huaquanxyid,zwt.huaquangwid,zwt.huakexyid,zwt.huakegwid,zwt.huajixyid,zwt.huajigwid
,zwt.daxianfrom,zwt.daxianto
from (
SELECT  TOP (100) PERCENT mz.mingzhuid,mz.MingZhu, mz.XingBie, mz.GongLi, mz.NongLi, gw.SValue AS GongWei, g.Gan, z.Zhi, 
(select zwxy.XingYao+',' from vZiWeiXY zwxy where zw.mingzhuid=zwxy .mingzhuid and  zw.gongweiid=zwxy .gongweiid 
and zwxy.xingyaotypeid=1 for XML PATH('')) as ZhengYaos,
(select zwxy.XingYao+',' from vZiWeiXY zwxy where zw.mingzhuid=zwxy .mingzhuid and  zw .gongweiid=zwxy .gongweiid 
and zwxy.xingyaotypeid in (2,3) for XML PATH('')) as FuYaos,
(select zwxy.XingYao+',' from vZiWeiXY zwxy where zw.mingzhuid=zwxy .mingzhuid and  zw .gongweiid=zwxy .gongweiid 
and zwxy.xingyaotypeid =4 for XML PATH('')) as ZaYaos,
(select zwxy.XingYao+',' from vZiWeiXY zwxy where zw.mingzhuid=zwxy .mingzhuid and  zw .gongweiid=zwxy .gongweiid 
and zwxy.xingyaotypeid =5 for XML PATH('')) as ChangShengYaos,
(select zwxy.XingYao+',' from vZiWeiXY zwxy where zw.mingzhuid=zwxy .mingzhuid and  zw .gongweiid=zwxy .gongweiid 
and zwxy.xingyaotypeid in(6,7,8) for XML PATH('')) as TaiSuiYaos,
                   hlxy.XingYao AS HLXY, hlgw.SValue AS HLGW, hqxy.XingYao AS HQXY, hqgw.SValue AS HQGW, hkxy.XingYao AS HKXY, 
                   hkgw.SValue AS HKGW, hjxy.XingYao AS HJXY, hjgw.SValue AS HJGW, zw.ZiWeiId, zw.PaiPanTypeId, 
                   zw.GongWeiId, zw.IsShengGong, zw.GanId, zw.ZhiId, zw.HuaLuXYId, zw.HuaLuGWId, zw.HuaQuanXYId, zw.HuaQuanGWId, 
                   zw.HuaKeXYId, zw.HuaKeGWId, zw.HuaJiXYId, zw.HuaJiGWId, zw.DaXianFrom, zw.DaXianTo
FROM      dbo.dZiWei AS zw LEFT OUTER JOIN
                   dbo.dMingZhu AS mz ON zw.MingZhuId = mz.MingZhuId LEFT OUTER JOIN
                   dbo.zSuanMing AS gw ON gw.SKey = 'zwGongWei' AND zw.GongWeiId = gw.SKeyId LEFT OUTER JOIN
                   dbo.zGan AS g ON zw.GanId = g.GanId LEFT OUTER JOIN
                   dbo.zZhi AS z ON zw.ZhiId = z.ZhiId LEFT OUTER JOIN
                   dbo.wXingYao AS hlxy ON hlxy.XingYaoId = zw.HuaLuXYId LEFT OUTER JOIN
                   dbo.zSuanMing AS hlgw ON hlgw.SKey = 'zwGongWei' AND hlgw.SKeyId = zw.HuaLuGWId LEFT OUTER JOIN
                   dbo.wXingYao AS hqxy ON hqxy.XingYaoId = zw.HuaQuanXYId LEFT OUTER JOIN
                   dbo.zSuanMing AS hqgw ON hqgw.SKey = 'zwGongWei' AND hqgw.SKeyId = zw.HuaQuanGWId LEFT OUTER JOIN
                   dbo.wXingYao AS hkxy ON hkxy.XingYaoId = zw.HuaKeXYId LEFT OUTER JOIN
                   dbo.zSuanMing AS hkgw ON hkgw.SKey = 'zwGongWei' AND hkgw.SKeyId = zw.HuaKeGWId LEFT OUTER JOIN
                   dbo.wXingYao AS hjxy ON hjxy.XingYaoId = zw.HuaJiXYId LEFT OUTER JOIN
                   dbo.zSuanMing AS hjgw ON hjgw.SKey = 'zwGongWei' AND hjgw.SKeyId = zw.HuaJiGWId
ORDER BY zw.MingZhuId, zw.GongWeiId
) as zwt

GO
/****** Object:  View [dbo].[vFeiXing]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vFeiXing] as 
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HLGW as ToGongWei,HLXY as XingYao,fx.Note from dmingzhu mz 
inner join vZiWeiGW zw on mz.MingZhuId = zw.MingZhuId and mz.NianGanId=zw.GanId
inner join wFeiXing fx on  zw.HuaLuGWId=fx.ToGongWeiID and  fx.FeiXingTypeId=1 and fx.FromGongWeiId is null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HLGW as ToGongWei,HLXY as XingYao,fx.Note from vZiWeiGW zw 
inner join wFeiXing fx on fx.FromGongWeiId = zw.GongWeiId and fx.ToGongWeiId = zw.HuaLuGWId 
and fx.FeiXingTypeId=1 and fx.FromGongWeiId is not null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HQGW as ToGongWei,HQXY as XingYao,fx.Note from dmingzhu mz 
inner join vZiWeiGW zw on mz.MingZhuId = zw.MingZhuId and mz.NianGanId=zw.GanId
inner join wFeiXing fx on  zw.HuaQuanGWId=fx.ToGongWeiID and  fx.FeiXingTypeId=2 and fx.FromGongWeiId is null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HQGW as ToGongWei,HQXY as XingYao,fx.Note from vZiWeiGW zw 
inner join wFeiXing fx on fx.FromGongWeiId = zw.GongWeiId and fx.ToGongWeiId = zw.HuaQuanGWId 
and fx.FeiXingTypeId=2 and fx.FromGongWeiId is not null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HKGW as ToGongWei,HKXY as XingYao,fx.Note from dmingzhu mz 
inner join vZiWeiGW zw on mz.MingZhuId = zw.MingZhuId and mz.NianGanId=zw.GanId
inner join wFeiXing fx on  zw.HuakeGWId=fx.ToGongWeiID and  fx.FeiXingTypeId=3 and fx.FromGongWeiId is null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HKGW as ToGongWei,HKXY as XingYao,fx.Note from vZiWeiGW zw 
inner join wFeiXing fx on fx.FromGongWeiId = zw.GongWeiId and fx.ToGongWeiId = zw.HuaKeGWId 
and fx.FeiXingTypeId=3 and fx.FromGongWeiId is not null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HJGW as ToGongWei,HJXY as XingYao,fx.Note from dmingzhu mz 
inner join vZiWeiGW zw on mz.MingZhuId = zw.MingZhuId and mz.NianGanId=zw.GanId
inner join wFeiXing fx on  zw.HuaJiGWId=fx.ToGongWeiID and  fx.FeiXingTypeId=4 and fx.FromGongWeiId is null 
union all
select zw.MingZhuId,zw.MingZHu,zw.XingBie,zw.GongLi,zw.NongLi,fx.FeiXing,zw.Gan,zw.Zhi,zw.GongWei as FromGongWei,zw.HJGW as ToGongWei,HJXY as XingYao,fx.Note from vZiWeiGW zw 
inner join wFeiXing fx on fx.FromGongWeiId = zw.GongWeiId and fx.ToGongWeiId = zw.HuaJIGWId 
and fx.FeiXingTypeId=4 and fx.FromGongWeiId is not null 

GO
/****** Object:  View [dbo].[vJiaZi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vJiaZi]
AS
SELECT  jz.JiaZiId, jz.jiaZiGanId, jz.JiaZiZhiId, jz.NaYinId, g.Gan, z.Zhi, ny.SValue,
                       (SELECT  WuHangId
                        FROM       dbo.zWuHang AS wh
                        WHERE    (SUBSTRING(ny.SValue, LEN(ny.SValue), 1) = WuHang)) AS WuHangiD
FROM      dbo.zJiaZi AS jz LEFT OUTER JOIN
                   dbo.zGan AS g ON g.GanId = jz.jiaZiGanId LEFT OUTER JOIN
                   dbo.zZhi AS z ON z.ZhiId = jz.JiaZiZhiId LEFT OUTER JOIN
                   dbo.zSuanMing AS ny ON ny.SKeyId = jz.NaYinId AND ny.SKey = 'bzNaYin'

GO
/****** Object:  View [dbo].[vRiToShi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vRiToShi]
AS
SELECT  g1.Gan, g2.Gan AS Expr1, t.GanId1, t.GanId2, t.ShiGanId, t.ShiZhiId, t.JiaZiId, t.jiaZiGanId, t.JiaZiZhiId, t.NaYinId, 
                   t.Gan AS Expr2, t.Zhi, t.SValue, t.WuHangiD
FROM      (SELECT  1 AS GanId1, 6 AS GanId2, jiaZiGanId AS ShiGanId, JiaZiZhiId AS ShiZhiId, JiaZiId, jiaZiGanId, JiaZiZhiId, NaYinId, 
                                      Gan, Zhi, SValue, WuHangiD
                   FROM       dbo.vJiaZi AS jz1
                   WHERE    (JiaZiId BETWEEN 1 AND 12)
                   UNION
                   SELECT  2 AS GanId1, 7 AS GanId2, jiaZiGanId AS ShiGanId, JiaZiZhiId AS ShiZhiId, JiaZiId, jiaZiGanId, JiaZiZhiId, NaYinId, 
                                      Gan, Zhi, SValue, WuHangiD
                   FROM      dbo.vJiaZi AS jz2
                   WHERE   (JiaZiId BETWEEN 13 AND 24)
                   UNION
                   SELECT  3 AS GanId1, 8 AS GanId2, jiaZiGanId AS ShiGanId, JiaZiZhiId AS ShiZhiId, JiaZiId, jiaZiGanId, JiaZiZhiId, NaYinId, 
                                      Gan, Zhi, SValue, WuHangiD
                   FROM      dbo.vJiaZi AS jz3
                   WHERE   (JiaZiId BETWEEN 25 AND 36)
                   UNION
                   SELECT  4 AS GanId1, 9 AS GanId2, jiaZiGanId AS ShiGanId, JiaZiZhiId AS ShiZhiId, JiaZiId, jiaZiGanId, JiaZiZhiId, NaYinId, 
                                      Gan, Zhi, SValue, WuHangiD
                   FROM      dbo.vJiaZi AS jz4
                   WHERE   (JiaZiId BETWEEN 37 AND 48)
                   UNION
                   SELECT  5 AS GanId1, 10 AS GanId2, jiaZiGanId AS ShiGanId, JiaZiZhiId AS ShiZhiId, JiaZiId, jiaZiGanId, JiaZiZhiId, NaYinId, 
                                      Gan, Zhi, SValue, WuHangiD
                   FROM      dbo.vJiaZi AS jz5
                   WHERE   (JiaZiId BETWEEN 49 AND 60)) AS t LEFT OUTER JOIN
                   dbo.zGan AS g1 ON t.GanId1 = g1.GanId LEFT OUTER JOIN
                   dbo.zGan AS g2 ON t.GanId2 = g2.GanId

GO
/****** Object:  View [dbo].[vBaZi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vBaZi]
AS
SELECT  TOP (100) PERCENT mz.MingZhuId, mz.MingZhu, mz.XingBie, mz.GongLi, mz.NongLi, CONVERT(nvarchar(10), dybz.Year) 
                   + '-' + CONVERT(nvarchar(10), dybz.Year + 9) AS DYPeriod, CONVERT(nvarchar(10), dybz.Year - mz.GongLiNian) 
                   + '-' + CONVERT(nvarchar(10), dybz.Year - mz.GongLiNian + 9) AS DYSui, dygss.SValue AS DYGSS, dyg.Gan AS DYGan, 
                   dyz.Zhi AS DYZhi, dyzcg1.Gan AS DYZCG1, dyzcg2.Gan AS DYZCG2, dyzcg3.Gan AS DYZCG3, 
                   dyzcgss1.SValue AS DYZCSS1, dyzcgss2.SValue AS DYZCSS2, dyzcgss3.SValue AS DYZCSS3, dyg.GanId AS DYGId, 
                   dyz.ZhiId AS DYZId, dyzcg1.GanId AS DYZCGId1, dyzcg2.GanId AS DYZCGId2, dyzcg3.GanId AS DYZCGId3, 
                   gzt.SKeyId AS GanZhiTypeId, gzt.SValue AS GanZhiType, bz.Year, gss.SValue AS GSS, g.Gan, z.Zhi, zcg1.Gan AS ZCG1, 
                   zcg2.Gan AS ZCG2, zcg3.Gan AS ZCG3, zcgss1.SValue AS ZCSS1, zcgss2.SValue AS ZCSS2, zcgss3.SValue AS ZCSS3, 
                   g.GanId, z.ZhiId, zcg1.GanId AS ZCGId1, zcg2.GanId AS ZCGId2, zcg3.GanId AS ZCGId3
FROM      dbo.dBaZi AS bz INNER JOIN
                   dbo.dMingZhu AS mz ON bz.MingZhuId = mz.MingZhuId INNER JOIN
                   dbo.zSuanMing AS gzt ON gzt.SKey = 'bzGanZhiType' AND bz.GanZhiTypeId = gzt.SKeyId LEFT OUTER JOIN
                   dbo.zSuanMing AS gss ON gss.SKey = 'bzShiSheng' AND bz.GanSSId = gss.SKeyId LEFT OUTER JOIN
                   dbo.zGan AS g ON bz.GanId = g.GanId LEFT OUTER JOIN
                   dbo.zZhi AS z ON bz.ZhiId = z.ZhiId LEFT OUTER JOIN
                   dbo.zGan AS zcg1 ON bz.ZhiCGanId1 = zcg1.GanId LEFT OUTER JOIN
                   dbo.zGan AS zcg2 ON bz.ZhiCGanId2 = zcg2.GanId LEFT OUTER JOIN
                   dbo.zGan AS zcg3 ON bz.ZhiCGanId3 = zcg3.GanId LEFT OUTER JOIN
                   dbo.zSuanMing AS zcgss1 ON zcgss1.SKey = 'bzShiSheng' AND bz.ZhiSSId1 = zcgss1.SKeyId LEFT OUTER JOIN
                   dbo.zSuanMing AS zcgss2 ON zcgss2.SKey = 'bzShiSheng' AND bz.ZhiSSId2 = zcgss2.SKeyId LEFT OUTER JOIN
                   dbo.zSuanMing AS zcgss3 ON zcgss3.SKey = 'bzShiSheng' AND bz.ZhiSSId3 = zcgss3.SKeyId LEFT OUTER JOIN
                   dbo.dBaZi AS dybz ON bz.BaZiRefId = dybz.BaZiId AND dybz.GanZhiTypeId = 5 LEFT OUTER JOIN
                   dbo.zGan AS dyg ON dybz.GanId = dyg.GanId LEFT OUTER JOIN
                   dbo.zZhi AS dyz ON dybz.ZhiId = dyz.ZhiId LEFT OUTER JOIN
                   dbo.zGan AS dyzcg1 ON dybz.ZhiCGanId1 = dyzcg1.GanId LEFT OUTER JOIN
                   dbo.zGan AS dyzcg2 ON dybz.ZhiCGanId2 = dyzcg2.GanId LEFT OUTER JOIN
                   dbo.zGan AS dyzcg3 ON dybz.ZhiCGanId3 = dyzcg3.GanId LEFT OUTER JOIN
                   dbo.zSuanMing AS dygss ON dygss.SKey = 'bzShiSheng' AND dybz.GanSSId = dygss.SKeyId LEFT OUTER JOIN
                   dbo.zSuanMing AS dyzcgss1 ON dyzcgss1.SKey = 'bzShiSheng' AND dybz.ZhiSSId1 = dyzcgss1.SKeyId LEFT OUTER JOIN
                   dbo.zSuanMing AS dyzcgss2 ON dyzcgss2.SKey = 'bzShiSheng' AND dybz.ZhiSSId2 = dyzcgss2.SKeyId LEFT OUTER JOIN
                   dbo.zSuanMing AS dyzcgss3 ON dyzcgss3.SKey = 'bzShiSheng' AND dybz.ZhiSSId3 = dyzcgss3.SKeyId
WHERE   (gzt.SKeyId IN (1, 2, 3, 4, 7))
ORDER BY bz.MingZhuId, GanZhiTypeId, bz.Year

GO
/****** Object:  View [dbo].[vSiHua]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vSiHua] as 
select shx.*,hlxy.XingYao as HL,hqxy.XingYao as HQ,hkxy.XingYao as HK,hjxy.XingYao as HJ from (
select g.GanId,g.Gan,hl.XingYaoId HLX,hq.XingYaoId HQX,hk.XingYaoId HKX,hj.XingYaoId HJX from zgan g
left join wgansihua hl on g.GanId = hl.GanId and hl.SiHuaId=1
left join wgansihua hq on g.GanId = hq.GanId and hq.SiHuaId=2
left join wgansihua hk on g.GanId = hk.GanId and hk.SiHuaId=3
left join wgansihua hj on g.GanId = hj.GanId and hj.SiHuaId=4
) as shx 
left join wXingYao hlxy on shx.HLX = hlxy.xingyaoid
left join wXingYao hqxy on shx.HQX = hqxy.xingyaoid
left join wXingYao hkxy on shx.HKX = hkxy.xingyaoid
left join wXingYao hjxy on shx.HJX = hjxy.xingyaoid
GO
/****** Object:  View [dbo].[vMingZhu]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vMingZhu]
AS
SELECT  TOP (100) PERCENT mz.MingZhuId, mz.MingZhu, mz.XingBie, CONVERT(varchar(19), mz.GongLi, 120) AS GongLi, mz.NongLi, 
                   mz.GongLiNian, mz.NongLiNian, DATEPART(year, GETDATE()) - mz.GongLiNian AS Sui, 
                   g1.Gan + z1.Zhi + ' ' + g2.Gan + z2.Zhi + ' ' + g3.Gan + z3.Zhi + ' ' + g4.Gan + z4.Zhi AS BaZiByJieQi, 
                   g1.Gan + z1.Zhi + ' ' + yg.Gan + yz.Zhi + ' ' + g3.Gan + z3.Zhi + ' ' + g4.Gan + z4.Zhi AS BaZiByYueFeng, ISNULL(mz.Note, '') 
                   AS Note, cjq.JieQi AS CurJieQi, pjq.JieQi AS PrevJieQi, mz.PreviousJieQiDate, njq.JieQi AS NextJieQi, mz.NextJieQiDate, 
                   mza.QiYunDateTime, mza.QiYunSui, wh.WuHangJu, wh.JuShu AS QiJuSui, 
                   sh.HL + ',' + sh.HQ + ',' + sh.HK + ',' + sh.HJ AS NianSiHua, CONVERT(varchar(19), mz.CreateDateTime, 120) 
                   AS CreateDateTime
FROM      dbo.dMingZhu AS mz LEFT OUTER JOIN
                   dbo.zGan AS g1 ON mz.NianGanId = g1.GanId LEFT OUTER JOIN
                   dbo.zGan AS g2 ON mz.YueGanId = g2.GanId LEFT OUTER JOIN
                   dbo.zGan AS g3 ON mz.RiGanId = g3.GanId LEFT OUTER JOIN
                   dbo.zGan AS g4 ON mz.ShiGanId = g4.GanId LEFT OUTER JOIN
                   dbo.zZhi AS z1 ON mz.NianZhiId = z1.ZhiId LEFT OUTER JOIN
                   dbo.zZhi AS z2 ON mz.YueZhiId = z2.ZhiId LEFT OUTER JOIN
                   dbo.zZhi AS z3 ON mz.RiZhiId = z3.ZhiId LEFT OUTER JOIN
                   dbo.zZhi AS z4 ON mz.ShiZhiId = z4.ZhiId LEFT OUTER JOIN
                   dbo.zJieQi AS cjq ON mz.CurrentJieQiId = cjq.JieQiId LEFT OUTER JOIN
                   dbo.zJieQi AS pjq ON mz.PreviousJieQiId = pjq.JieQiId LEFT OUTER JOIN
                   dbo.zJieQi AS njq ON mz.NextJieQiId = njq.JieQiId LEFT OUTER JOIN
                   dbo.dMingZhuAdd AS mza ON mz.MingZhuId = mza.MingZhuId LEFT OUTER JOIN
                   dbo.dMingZhuZWAdd AS mzza ON mz.MingZhuId = mzza.MingZhuId LEFT OUTER JOIN
                   dbo.zWuHang AS wh ON mzza.WuHangId = wh.WuHangId LEFT OUTER JOIN
                   dbo.zGan AS yg ON yg.GanId = mzza.YueGanId LEFT OUTER JOIN
                   dbo.zZhi AS yz ON yz.ZhiId = mzza.YueZhiId LEFT OUTER JOIN
                   dbo.vSiHua AS sh ON mz.NianGanId = sh.GanId
ORDER BY CreateDateTime DESC, mz.MingZhu

GO
/****** Object:  View [dbo].[vBaZiSS]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vBaZiSS]
AS
SELECT  mz.MingZhuId, mz.MingZhu AS 命主, mz.XingBie AS 性别, mz.GongLi AS 公历, mz.NongLi AS 农历, bz1.GSS + CHAR(13) 
                   + bz1.Gan + CHAR(13) + bz1.Zhi + CHAR(13) + bz1.ZCG1 + ISNULL(bz1.ZCG2, N'') + ISNULL(bz1.ZCG3, N'') + CHAR(13) 
                   + bz1.ZCSS1 + CHAR(13) + ISNULL(bz1.ZCSS2, N'') + CHAR(13) + ISNULL(bz1.ZCSS3, N'') AS 年柱, bz2.GSS + CHAR(13) 
                   + bz2.Gan + CHAR(13) + bz2.Zhi + CHAR(13) + bz2.ZCG1 + ISNULL(bz2.ZCG2, N'') + ISNULL(bz2.ZCG3, N'') + CHAR(13) 
                   + bz2.ZCSS1 + CHAR(13) + ISNULL(bz2.ZCSS2, N'') + CHAR(13) + ISNULL(bz2.ZCSS3, N'') AS 月柱, ISNULL(bz3.GSS, N'') 
                   + CHAR(13) + ISNULL(bz3.Gan, N'') + CHAR(13) + bz3.Zhi + CHAR(13) + bz3.ZCG1 + ISNULL(bz3.ZCG2, N'') + ISNULL(bz3.ZCG3, 
                   N'') + CHAR(13) + bz3.ZCSS1 + CHAR(13) + ISNULL(bz3.ZCSS2, N'') + CHAR(13) + ISNULL(bz3.ZCSS3, N'') AS 日柱, 
                   bz4.GSS + CHAR(13) + bz4.Gan + CHAR(13) + bz4.Zhi + CHAR(13) + bz4.ZCG1 + ISNULL(bz4.ZCG2, N'') + ISNULL(bz4.ZCG3, N'') 
                   + CHAR(13) + bz4.ZCSS1 + CHAR(13) + ISNULL(bz4.ZCSS2, N'') + CHAR(13) + ISNULL(bz4.ZCSS3, N'') AS 时柱, 
                   bz5.DYGSS + CHAR(13) + bz5.DYGan + CHAR(13) + bz5.DYZhi + CHAR(13) + bz5.DYZCG1 + ISNULL(bz5.DYZCG2, N'') 
                   + ISNULL(bz5.DYZCG3, N'') + CHAR(13) + bz5.DYZCSS1 + CHAR(13) + ISNULL(bz5.DYZCSS2, N'') + CHAR(13) 
                   + ISNULL(bz5.DYZCSS3, N'') AS 大运, bz5.GSS + CHAR(13) + bz5.Gan + CHAR(13) + bz5.Zhi + CHAR(13) 
                   + bz5.ZCG1 + ISNULL(bz5.ZCG2, N'') + ISNULL(bz5.ZCG3, N'') + CHAR(13) + bz5.ZCSS1 + CHAR(13) + ISNULL(bz5.ZCSS2, N'') 
                   + CHAR(13) + ISNULL(bz5.ZCSS3, N'') AS 流年, bz5.DYPeriod AS 当前大运, bz5.DYSui AS 大运岁数, bz5.Year AS 当前年份, 
                   bz5.Year - mz.GongLiNian AS 当前岁数
FROM      dbo.vMingZhu AS mz LEFT OUTER JOIN
                   dbo.vBaZi AS bz1 ON mz.MingZhuId = bz1.MingZhuId AND bz1.GanZhiType = '年' LEFT OUTER JOIN
                   dbo.vBaZi AS bz2 ON mz.MingZhuId = bz2.MingZhuId AND bz2.GanZhiType = '月' LEFT OUTER JOIN
                   dbo.vBaZi AS bz3 ON mz.MingZhuId = bz3.MingZhuId AND bz3.GanZhiType = '日' LEFT OUTER JOIN
                   dbo.vBaZi AS bz4 ON mz.MingZhuId = bz4.MingZhuId AND bz4.GanZhiType = '时' LEFT OUTER JOIN
                   dbo.vBaZi AS bz5 ON mz.MingZhuId = bz5.MingZhuId AND bz5.GanZhiType = '流年' AND bz5.Year = CONVERT(int, 
                   CONVERT(nvarchar(4), GETDATE(), 120))

GO
/****** Object:  View [dbo].[vGanZhiGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vGanZhiGX] as 
	  select gzgxt.SValue as GXType,gx.*,g1.Gan as GanZhi1,g2.Gan as GanZhi2,null as GanZhi3,gzgx.SValue as GanZhiGX
	  ,wh.wuhang as GXValue from zGanZhiGX gx
	  left join zsuanming gzgxt on gx.gxtypeid=gzgxt.skeyid and gzgxt.skey='bzGanZhiGXType'
	  left join zgan g1 on g1.ganid=gx.ganzhiid1 
	  left join zgan g2 on g2.ganid=gx.ganzhiid2 
	  left join zsuanming gzgx on gzgx.skey= 'bzGanZhiGX' and gx.GanZhiGXId=gzgx.SKeyId
	  left join zWuHang wh on wh.WuHangId=gxvalueid
	  where gxtypeid =1
	  union
	  select gzgxt.SValue as GXType,gx.*,z1.Zhi as GanZhi1,z2.Zhi as GanZhi2,z3.Zhi as GanZhi3,gzgx.SValue as GanZhiGX
	  ,wh.wuhang as GXValue from zGanZhiGX gx
	  left join zsuanming gzgxt on gx.gxtypeid=gzgxt.skeyid and gzgxt.skey='bzGanZhiGXType'
	  left join zzhi z1 on z1.zhiid=gx.ganzhiid1 
	  left join zzhi z2 on z2.zhiid=gx.ganzhiid2 
	  left join zzhi z3 on z3.zhiid=gx.ganzhiid3
	  left join zsuanming gzgx on gzgx.skey= 'bzGanZhiGX' and gx.GanZhiGXId=gzgx.SKeyId
	  left join zWuHang wh on wh.WuHangId=gxvalueid
	  where gxtypeid =2
	  union
	  select gzgxt.SValue as GXType,gx.*,g1.Gan as GanZhi1,g2.Gan as GanZhi2,null as GanZhi3,null as GanZhiGX
	  ,ss.SValue as GXValue from zGanZhiGX gx
	  left join zsuanming gzgxt on gx.gxtypeid=gzgxt.skeyid and gzgxt.skey='bzGanZhiGXType'
	  left join zgan g1 on g1.ganid=gx.ganzhiid1 
	  left join zgan g2 on g2.ganid=gx.ganzhiid2 
	  left join zsuanming ss on ss.skey= 'bzShiSheng' and gx.GXValueId=ss.SKeyId
	  where gxtypeid =3
	  union
	  select gzgxt.SValue as GXType,gx.*,g.Gan as GanZhi1,z.zhi as GanZhi2,null as GanZhi3,null as GanZhiGX
	  ,ss.SValue as GXValue from zGanZhiGX gx
	  left join zsuanming gzgxt on gx.gxtypeid=gzgxt.skeyid and gzgxt.skey='bzGanZhiGXType'
	  left join zgan g on g.ganid=gx.ganzhiid1 
	  left join zzhi z on z.zhiid=gx.ganzhiid2 
	  left join zsuanming ss on ss.skey= 'bzWangShuai' and gx.GXValueId=ss.SKeyId
	  where gxtypeid =4 
GO
/****** Object:  View [dbo].[vMiaoXian]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[vMiaoXian] as 
select mxgx.*,xy.XingYao,z.Zhi,mx.MiaoXian
 from wXingYao xy 
left join wMiaoXianGX mxgx on xy.XingYaoId = mxgx.XingYaoId
left join zZhi z on mxgx.zhiid = z.ZhiId
left join wMiaoXian mx on mxgx.MiaoXianId = mx.MiaoXianId

GO
/****** Object:  View [dbo].[vMingZhuSS]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vMingZhuSS]
AS
SELECT  TOP (100) PERCENT mz.MingZhu, gzt.SValue AS GanZhiType, ss.SValue AS ShengSha, mzss.MingZhuId, mzss.ShengShaId, 
                   mzss.GanZhiTypeId, mzss.Remark, mzss.CreateDateTime
FROM      dbo.dMingZhuSS AS mzss LEFT OUTER JOIN
                   dbo.dMingZhu AS mz ON mzss.MingZhuId = mz.MingZhuId LEFT OUTER JOIN
                   dbo.zSuanMing AS ss ON mzss.ShengShaId = ss.SKeyId AND ss.SKey = 'bzShengSha' LEFT OUTER JOIN
                   dbo.zSuanMing AS gzt ON mzss.GanZhiTypeId = gzt.SKeyId AND gzt.SKey = 'bzGanZhiType'
ORDER BY mzss.GanZhiTypeId

GO
/****** Object:  View [dbo].[vMSGongWei]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vMSGongWei]
AS
SELECT  yz.Zhi AS YZhi, sz.Zhi AS SZhi, mgz.Zhi AS MGZhi, sgz.Zhi AS SGZhi, t.YZhiId, t.SZhiId, t.MGZhiId, t.SGZhiId, t.SGGongWeiId, 
                   t.SGGongWei
FROM      (SELECT  msgw.YZhiId, msgw.SZhiId, msgw.MGZhiId, msgw.SGZhiId, gw.SKeyId AS SGGongWeiId, 
                                      gw.SValue AS SGGongWei
                   FROM       (SELECT  yz.ZhiId AS YZhiId, sz.ZhiId AS SZhiId, dbo.fZhiOffset(yz.ZhiId, sz.ZhiId, 0) AS MGZhiId, 
                                                          dbo.fZhiOffset(yz.ZhiId, sz.ZhiId, 1) AS SGZhiId
                                       FROM       dbo.zZhi AS yz CROSS JOIN
                                                          dbo.zZhi AS sz) AS msgw LEFT OUTER JOIN
                                      dbo.zSuanMing AS gw ON msgw.SGZhiId > msgw.MGZhiId AND (msgw.SGZhiId - msgw.MGZhiId + 1) 
                                      % 12 = gw.SKeyId OR
                                      msgw.SGZhiId <= msgw.MGZhiId AND (msgw.SGZhiId - msgw.MGZhiId + 13) % 12 = gw.SKeyId
                   WHERE    (gw.SKey = 'zwGongWei')) AS t LEFT OUTER JOIN
                   dbo.zZhi AS yz ON t.YZhiId = yz.ZhiId LEFT OUTER JOIN
                   dbo.zZhi AS sz ON t.SZhiId = sz.ZhiId LEFT OUTER JOIN
                   dbo.zZhi AS mgz ON t.MGZhiId = mgz.ZhiId LEFT OUTER JOIN
                   dbo.zZhi AS sgz ON t.SGZhiId = sgz.ZhiId

GO
/****** Object:  View [dbo].[vNianToYue]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vNianToYue]
AS
SELECT  TOP (100) PERCENT ny.GanId1, ny.GanId2, ny.YueGanId, ny.YueZhiId, g1.Gan AS Gan1, g2.Gan AS Gan2, 
                   yg.Gan AS YueGan, yz.Zhi AS YueZhi
FROM      (SELECT  TOP (100) PERCENT GanId1, GanId2, YueGanId, YueZhiId
                   FROM       (SELECT  1 AS GanId1, 6 AS GanId2, jiaZiGanId AS YueGanId, JiaZiZhiId AS YueZhiId
                                       FROM       dbo.zJiaZi
                                       WHERE    (JiaZiId BETWEEN 3 AND 14)
                                       UNION
                                       SELECT  2 AS GanId1, 7 AS GanId2, jiaZiGanId AS YueGanId, JiaZiZhiId AS YueZhiId
                                       FROM      dbo.zJiaZi AS zJiaZi_4
                                       WHERE   (JiaZiId BETWEEN 15 AND 26)
                                       UNION
                                       SELECT  3 AS GanId1, 8 AS GanId2, jiaZiGanId AS YueGanId, JiaZiZhiId AS YueZhiId
                                       FROM      dbo.zJiaZi AS zJiaZi_3
                                       WHERE   (JiaZiId BETWEEN 27 AND 38)
                                       UNION
                                       SELECT  4 AS GanId1, 9 AS GanId2, jiaZiGanId AS YueGanId, JiaZiZhiId AS YueZhiId
                                       FROM      dbo.zJiaZi AS zJiaZi_2
                                       WHERE   (JiaZiId BETWEEN 39 AND 50)
                                       UNION
                                       SELECT  5 AS GanId1, 10 AS GanId2, jiaZiGanId AS YueGanId, JiaZiZhiId AS YueZhiId
                                       FROM      dbo.zJiaZi AS zJiaZi_1
                                       WHERE   (JiaZiId BETWEEN 51 AND 60) OR
                                                          (JiaZiId BETWEEN 1 AND 2)) AS derivedtbl_1) AS ny LEFT OUTER JOIN
                   dbo.zGan AS g1 ON g1.GanId = ny.GanId1 LEFT OUTER JOIN
                   dbo.zGan AS g2 ON g2.GanId = ny.GanId2 LEFT OUTER JOIN
                   dbo.zGan AS yg ON yg.GanId = ny.YueGanId LEFT OUTER JOIN
                   dbo.zZhi AS yz ON yz.ZhiId = ny.YueZhiId
ORDER BY ny.GanId1, ny.YueZhiId

GO
/****** Object:  View [dbo].[vWuHangGX]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view  [dbo].[vWuHangGX] as 
select wh1.WuHang as WuHangKe,sk.SValue as WuHangZhu,wh2.WuHang,whgx.* from zWuHangGX whgx
left join zwuhang wh1 on wh1.WuHangId=whgx.KeTiId
left join zwuhang wh2 on wh2.WuHangId=whgx.ZhuTiId
left join zsuanming sk on skey = 'bzShengKe' and whgx.ShengKeId=skeyid

GO
/****** Object:  View [dbo].[vXingYaoZhi]    Script Date: 2016/6/14 21:17:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[vXingYaoZhi] as 

select ZWZhiId,ZWZhi N'紫薇',TJZhiId,tjz.Zhi  N'天机',TYAZhiId,tyaz.Zhi N'太阳'
,WQZhiId,wqz.Zhi N'武曲',TTZhiId,tt.Zhi N'天同',LZZhiId,lz.Zhi N'廉贞'
,TFZhiId,tf.Zhi N'天府',TYIZhiId,tyi.Zhi N'天阴',TLAZhiId,tla.Zhi N'贪狼',JMZhiId,jm.Zhi N'巨门'
,TXZhiId,tx.Zhi N'天相',TLZhiId,tl.Zhi N'天梁',QSZhiId,qs.Zhi N'七杀',PJZhiId,pj.Zhi N'破军' from (
select ZWZhiId,ZWZhi,dbo.fZhiOffset(ZWZhiId,2,0) as TJZhiId,dbo.fZhiOffset(ZWZhiId,4,0) as TYAZhiId
,dbo.fZhiOffset(ZWZhiId,5,0) as WQZhiId,dbo.fZhiOffset(ZWZhiId,6,0) as TTZhiId,dbo.fZhiOffset(ZWZhiId,9,0) as LZZhiId
,TFZhiId,dbo.fZhiOffset(TFZhiId,2,1) as TYIZhiId,dbo.fZhiOffset(TFZhiId,3,1) as TLAZhiId,dbo.fZhiOffset(TFZhiId,4,1) as JMZhiId
,dbo.fZhiOffset(TFZhiId,5,1) as TXZhiId,dbo.fZhiOffset(TFZhiId,6,1) as TLZhiId,dbo.fZhiOffset(TFZhiId,7,1) as QSZhiId
,dbo.fZhiOffset(TFZhiId,11,1) as PJZhiId from (
select ZhiId as ZWZhiId,Zhi as ZWZhi,6-ZhiId as TFZhiId from zzhi where zhiid<6
union
select ZhiId as ZWZhiId,Zhi as ZWZhi,18-ZhiId as TFZhiId from zzhi where zhiid>=6
) as xy
) as xyz
left join zzhi tjz on TJZhiId=tjz.zhiid
left join zzhi tyaz on TYAZhiId=tyaz.zhiid
left join zzhi wqz on WQZhiId=wqz.zhiid
left join zzhi tt on TTZhiId=tt.zhiid
left join zzhi lz on LZZhiId=lz.zhiid
left join zzhi tf on TFZhiId=tf.zhiid
left join zzhi tyi on TYIZhiId=tyi.zhiid
left join zzhi tla on TLAZhiId=tla.zhiid
left join zzhi jm on JMZhiId=jm.zhiid
left join zzhi tx on TXZhiId=tx.zhiid
left join zzhi tl on TLZhiId=tl.zhiid
left join zzhi qs on QSZhiId=qs.zhiid
left join zzhi pj on PJZhiId=pj.zhiid
GO
INSERT [dbo].[dMingZhuZWAdd] ([MingZhuId], [WuHangId], [YueGanId], [YueZhiId]) VALUES (1112, 3, 1, 11)
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在命宫', NULL, 1, N'1 福气，人生容易混，一生容易衣食无忧。 
2 生年禄在命的人，谁都好接触，为什么呢？命代表性格，有禄，通情达理，随 缘不固执，好相处，人缘佳。以后也容易得配偶和子女的喜欢。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在兄弟', NULL, 12, N'1 兄弟是我的福，手足情深。 
2 兄弟宫，成就位，也是银行存款位。个人经济情况好，事业容易开展的顺利， 容易步步高升，人生很好混啦。您就是缺钱，也容易柳暗花明又一村。 
3 兄弟也是体质位。精气神不错，体质不错，兄弟也代表闺房，有禄，性生活也 
能好些。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在夫妻', NULL, 11, N'1 异性缘超级好。夫妻代表你有缘接触的异性，不仅仅代表老公老婆。 
2 容易因为婚姻得福，另一半通情达理。但是，由于第一条异性缘好，却成了婚 姻的伏笔啊。。。禄在夫妻有时候好事变坏事啊。。。。。。不过一般夫妻宫有禄，你 出轨了，你的另一半原谅你的几率比较高，谁让他好说话呢。 
2 夫妻也是福分财，容易上辈子做好事，这辈子带来的财多一些。如果是廉贞贪 
狼破军这种偏财星化禄，容易有彩票的缘份。彩票能不能得，绝对是累世的福啊。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在子女', NULL, 10, N'1 孩子好，不容易学坏，老了有人照顾你。 
2 子女宫还代表小辈，不一定是你孩子哦，小辈福气好，比如你要是老师，你容 易桃李满天下，另外，你要是领导，下属也帮助你。 
3 子女还是合作合伙的宫位，容易和别人一起做一个事情，合作愉快。 
4 子女也是性的宫位，容易性福，也代表女人的子宫。子女也是情人的宫位，遇 
到大桃花星贪狼或者廉贞化禄，大老婆二老婆，大老公二老公的，多了你哄不过 
来。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在财帛', NULL, 9, N'1 和财有缘，财路好，平日挣钱顺利，尤其手里现金不缺。 
2 也可能是别人送你的钱啊，别人供养你。 
3 容易做分红工作，比如销售之类的，那红利股股而来的。 
4 婚姻对待好。和钱有缘，所以，婚姻也容易幸福，不为几块钱两口子打架啦 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在疾厄', NULL, 8, N'1 疾厄是身体，容易懒，发胖，喜欢逍遥自在，少收病痛折磨。 
2 疾厄也是家运位，家里条件容易好，所以你才有机会懒。爸爸一般能干。 
3 如果是桃花星廉贞或贪狼化禄，你还能有艳遇。 
4 疾厄也是情绪，有禄，也是不固执，好接触。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在迁移', NULL, 7, N'1 迁移是果报的宫位，代表你果报里有福，有不期而遇的好事，偏财星廉贞贪狼 破军化禄，也容易有彩票的缘分。一些大根器的人，也是果报宫位漂亮。 
2 迁移是广大社会，你走出去，很多人欢迎你，给你鼓掌，也是名气。容易外面 
机遇好。众人让你水涨船高。迁移漂亮，社会地位容易高，到处都能混名堂。 
3 迁移也是形于外的宫位，别人看的到的地方。你个人是明亮的，圆融的，幽默的，讨人喜欢的。容易和贵人攀缘，容易做业绩和分红的工作。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在交友', NULL, 6, N'1 有同辈福，他们能帮你。交友宫代表同辈：朋友 同事 客户。 
2 你肯定也有待人愉悦的一面。 
3 如果是桃花星廉贞贪狼化禄，你桃花机会就很多了。朋友一起喝茶聊天，您就 桃花来了。 
4 有利于考试竞争。管理人的人，最好交友有禄，否则没人拥护你，你也当不上领导。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在事业 ', NULL, 5, N'1 即使你不太用心，事业也能很顺利，机会多，工作如意。 
2 比别人运气好，小时候读书不错。 
3 要是桃花星贪狼廉贞化禄，事业是夫妻的迁移，也代表婚外情机会多啊。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在田宅', NULL, 4, N'1 享受家庭福，天伦之乐，家人容易平顺长寿，门风也好。 
2 容易家庭物质条件不错，让你衣食无忧，得到不动产的几率也大。 
3 如果是偏财星廉贞贪狼破军，更是容易富有，田宅是最大的财库。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在福德', NULL, 3, N'1 乐天，知足，少计较，不强求，容易心情安逸的享受人生，别人也好接触 
2 福德是果报，福报好，容易心想事成，不求自得，偏财旺（廉贞贪狼破军化禄） 
3 兴趣广，爱好多，适合从事自己喜欢的，或者和愉悦心灵有关的工作 
4 懒，逍遥，不坚持，自在，晚运好。 
5 也是才华位，贪狼、廉贞在福德化禄，才华横溢。天机、天梁禄容易有佛道缘。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'生年禄在父母', NULL, 2, N'1 父母是福，父母爱你疼你供养你，也代表长辈，有长辈帮你，领导帮你。 
2 父母也是形于外的宫位，别人都看的到的，也代表名气。所以你容易有涵养， 形象不错，讨喜，会说话。 
3 父母是政府，容易有公职的机会；父母是交友的财帛，也是银行。你容易和人 金钱往来顺利，少贷款压力，少文书麻烦。 
4 父母也是学习的宫位，容易学习不错或者有秘密的独门学习技能。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入兄弟', 1, 12, N'我经济收入不错，工作容易提升，我对兄弟不错')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入夫妻', 1, 11, N'我对异性温柔多情，很包容，也容易自作多情 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入子女', 1, 10, N'我喜欢小孩，喜欢外面，容易和别人一起进行合作，性趣高')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入财帛', 1, 9, N'我挣钱不积极也能挣的不错，和钱有缘，容易做业绩分红的工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入疾厄', 1, 8, N'我懒，喜欢逍遥，容易心情好，也不容易受病痛折磨')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入迁移', 1, 7, N'我外缘明亮，喜欢与人攀缘，走出去也常受众人喜欢 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入交友', 1, 6, N'我对朋友温和友善，包容，接人待物不走极端 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入事业', 1, 5, N'我对工作不积极也能做的不错 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入田宅', 1, 4, N'我喜欢家庭的天伦之乐，也容易经济条件好，懒喜欢享福')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入福德', 1, 3, N'我想的开，知足常乐，懒，逍遥自在乐天，给自己精神充电')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命禄入父母', 1, 2, N'我彬彬有礼，尊敬长辈，善于讨喜，爱读书 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'命自化禄', 1, 1, N'乐观通达好相处，随性，无原则的好人，也常信口开河，容易被骗')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入命', 12, 1, N'兄弟和我感情好，生来经济条件不错，没有很大负担')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入夫妻', 12, 11, N'兄弟对异性温柔多情，我少婆媳妯娌问题')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入子女', 12, 10, N'我给小孩零花钱充裕，经济好多支出')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入财帛', 12, 9, N'从存款里拿出钱来放兜里花，支出方便，少理财观念 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入疾厄', 12, 8, N'物质生活好，兄弟感情不错，工作不累，身体气足')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入迁移', 12, 7, N'有发财、步步高升的机会，人生好混啊')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入交友', 12, 6, N'经济好支出方便，与人金钱多往来，做人潮生意')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入事业', 12, 5, N'兄弟事业顺利，我也资金充足，循环盈利')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入田宅', 12, 4, N'兄弟亲人感情好，我资金足，财富蒸蒸日上')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入福德', 12, 3, N'身体精气神足，经济充裕 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟禄入父母', 12, 2, N'我经济好，信用好（父母银行位）。兄弟嘴甜讨好。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'兄弟宫自化禄', 12, 1, N'经济看上去良好，少有计划，兄弟随性靠不住，财富容易被劫 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入命', 11, 1, N'异性缘非常好，配偶喜欢我，容易婚姻得福，异性客户多')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入兄弟', 11, 12, N'配偶容易经济条件好，配偶量大，情缘早发')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入子女', 11, 10, N'配偶喜欢小孩，配偶容易往外跑')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入财帛', 11, 9, N'彼此对待很不错，小事不计较，有异性带财的可能')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入疾厄', 11, 8, N'配偶对我体贴，让我快乐，容易身体接触或一夜情（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入迁移', 11, 7, N'配偶让我脸上有光，得异性庇荫，配偶在外表现圆融明亮')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入交友', 11, 6, N'异性朋友多，配偶也人缘好，要防桃花多情（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入事业', 11, 5, N'配偶异性帮助我工作，防桃花多情（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入田宅', 11, 4, N'容易结婚置产，配偶顾家荫家庭，配偶经济条件不错')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入福德', 11, 3, N'配偶让我心灵愉快，愉快的婚姻，也要防桃花多（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻禄入父母', 11, 2, N'名正言顺的婚姻，配偶比较讨长辈欢喜')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'夫妻宫自化禄', 11, 1, N'异性缘旺，却不长久，无原则的恋爱，春花秋月意乱情迷 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入命', 10, 1, N'子女和我亲近，有子福，适合小孩子工作，合作缘好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入兄弟', 10, 12, N'子女收入好，子女体质好，合伙缘好，性生活好 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入夫妻', 10, 11, N'性生活好，容易因孕而婚，合作缘好，亲戚促成婚姻')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入财帛', 10, 9, N'子女能挣钱，适合小孩生意，合作带财')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入疾厄', 10, 8, N'子女和我亲，小孩子粘着我，容易多桃花（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入迁移', 10, 7, N'小辈让我脸上有光，子女外缘好，合作缘旺')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入交友', 10, 6, N'容易和小辈打成一片，子女人缘好，性生活好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入事业', 10, 5, N'合伙合作缘旺，子女喜欢工作，适合做小孩子生意 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入田宅', 10, 4, N'子女荫家庭，适合小孩子生意，容易多桃花（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入福德', 10, 3, N'子女让我开心，喜欢小孩子单纯，性生活好，合伙缘好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女禄入父母', 10, 2, N'子女嘴甜讨喜，子女喜欢读书，容易遇到好老师')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'子女宫自化禄', 10, 10, N'对子女少用心，遇桃花星，一夜情，没原则的滥桃花')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入命', 9, 1, N'挣钱轻松，适合分红的业务工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入兄弟', 9, 12, N'收入好不累，进财增进之像，有钱就存银行，适合业务工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入夫妻', 9, 11, N'进财顺畅，彼此对待好，不和配偶计较金钱')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入子女', 9, 10, N'给子女零花钱充足，有合伙挣钱的缘分，花钱随性不计划 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入疾厄', 9, 8, N'挣钱轻松，让身体愉快，花钱随性不计划，适合分红工作 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入迁移', 9, 7, N'财路广，财源活络，适合得人缘的业务公关销售工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入交友', 9, 6, N'人际热络，给人花钱不计较，生意有人气')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入事业', 9, 5, N'生意好，现金周转快，有循环投资之像，变现快的现金生意')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入田宅', 9, 4, N'进财顺畅，有钱喜欢存起来买房，可经营房地产或者旅馆休闲')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入福德', 9, 3, N'乐观有财，把钱也花到自己心灵喜好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛禄入父母', 9, 2, N'多与人金钱往来，供养父母，信誉好，容易是银行工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'财帛自化禄', 9, 9, N'来财容易，少理财计划，它宫飞忌容易被劫。适合日日见财的生意')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入命', 8, 1, N'懒，随遇而安，好心情，不勤奋，与媳妇好相处')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入兄弟', 8, 12, N'身体精气神好，工作顺利不忙禄，身体亲近兄弟')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入夫妻', 8, 11, N'容易发胖，懒，身体亲近配偶，肢体传情，家运好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入子女', 8, 10, N'身体亲近子女、小辈，情欲多（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入财帛', 8, 9, N'挣钱轻松，享现成，怕累，挣风花雪月的软钱（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入迁移', 8, 7, N'逍遥，喜欢旅行，脾气随和，容易发胖，工作环境好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入交友', 8, 6, N'很亲近朋友，随和亲切，人气生意，防桃花（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入事业', 8, 5, N'工作不累轻松，也不太积极，工作环境大又好，易胖')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入田宅', 8, 4, N'身体喜欢亲近家人，与家人相处时间多，家运好，家安定宅祥和')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入福德', 8, 3, N'懒的动，身心逍遥，家运好，无久病纠缠 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄禄入父母', 8, 2, N'脾气好，举止温和有礼，身体亲近长辈（父母） ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'疾厄自化禄', 8, 8, N'安逸，懒，享受生活。漫不经心，欠积极')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入命', 7, 1, N'福报好，际遇好，社会资源让我开心，天赋根器')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入兄弟', 7, 12, N'八面来财，步步高升，社会资源惠我经济，适合业务运作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入夫妻', 7, 11, N'容易遇到较多情缘，对异性有办法（桃花星），受异性青睐')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入子女', 7, 10, N'愉快的出行，在小辈面前形象好，飞来艳福（桃花星），容易处理小辈的事，出门在外也容易过的不错')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入财帛', 7, 9, N'财路广，很会选择财路，搞业务，善于攀缘使得财源广进')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入疾厄', 7, 8, N'愉快的出行，常有旅游出行的机会，让心情放松自在')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入交友', 7, 6, N'善于人脉运作，广交际，长袖善舞。有群众魅力，演艺人员。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入事业', 7, 5, N'工作机遇好，善攀缘，外出好赚钱，也容易搞业务进财顺畅')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入田宅', 7, 4, N'果报荫我家宅、让我发富，容易外出置产，外出可衣锦还乡')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入福德', 7, 3, N'逍遥自在，想得开，果报让我开心，天降好事，根器好才华好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移禄入父母', 7, 2, N'善于察言观色，学习缘厚，见多识广，所学可用，与长辈攀缘')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'迁移自化禄', 7, 7, N'外缘不错，喜欢新鲜，容易受外界影响，遇到他宫忌，被牵着走')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入命', 6, 1, N'同辈对我好，人际获福，多的人帮助，也利于考试竞争')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入兄弟', 6, 12, N'朋友到我身边来，因为人际容易八方来财（休闲人潮生意）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入夫妻', 6, 11, N'异性朋友多，婚后朋友多，放桃花（桃花星），配偶容易发胖')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入子女', 6, 10, N'小辈缘好，有小辈忘年交，朋友来合作，配偶性能力好（桃花星）')
GO
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入财帛', 6, 9, N'朋友帮我挣钱，对我不计较，多与人金钱往来，也多生意朋友。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入疾厄', 6, 8, N'朋友喜欢和我在一起，亲近我身体，人潮生意，防桃花（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入迁移', 6, 7, N'朋友让我脸上有光，社交圈广，得人脉帮助')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入事业', 6, 5, N'朋友帮我事业，客人也帮我工作，多给予我方便，利于升职竞争')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入田宅', 6, 4, N'人气旺，客源好，人际带大财，可以从事人潮生意（休闲餐饮）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入福德', 6, 3, N'朋友让我开心，人缘热闹，气味相投少费心机，喜欢聊天喝茶')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友禄入父母', 6, 2, N'朋友多有涵养，有学识，人际和气愉悦，有长辈的忘年交')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'交友自化禄', 6, 6, N'看似朋友都不错，对朋友没原则，老好人一个，多奉承，少知己')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入命', 5, 1, N'运气好，工作乐观顺手，不累，容易自由职业、宜业绩分红')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入兄弟', 5, 12, N'事业多顺手，不累，业绩分红，高收入')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入夫妻', 5, 11, N'适合异性为对象的工作，婚后事业顺利，防婚外情（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入子女', 5, 10, N'适合小孩子为对象的工作，合作合伙，我的工作庇荫子女 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入财帛', 5, 9, N'现金循环回收快，适合变现快的生意，工作也容易高薪分红')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入疾厄', 5, 8, N'工作轻松不累，职场顺心让我愉快，高薪业绩分红，也可以生意')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入迁移', 5, 7, N'善于攀缘向外发展，口碑好，广得人和，适合公关销售的业务')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入交友', 5, 6, N'职场人气好，广得人际帮助，客户多，适合批发和服务业 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入田宅', 5, 4, N'事业荫家庭，适合和家有关的工作（房地产，旅店） ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入福德', 5, 3, N'工作让我心灵愉悦，容易做上喜欢的工作，适合人潮休闲类工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业禄入父母', 5, 2, N'容易公职，得上级满意，步步高升，前途光明。长辈慈善生意。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'事业自化禄', 5, 5, N'不适合生产行业，适合小本，回收快的生意 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入命', 4, 1, N'家庭庇荫我，享现成，生活优渥，得助置产，常受宠爱，不担家计')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入兄弟', 4, 12, N'家好库盈，生活优渥，容易投资，可以店家合一，自家开店盈利 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入夫妻', 4, 11, N'结婚置产，婚后经济变好，家人相处愉快，房地产盈利（偏财星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入子女', 4, 10, N'家业传小孩，庇荫子孙，容易不动产买卖，从事小孩子工作 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入财帛', 4, 9, N'家好库盈，支出方便，少有理财计划，容易投资休闲业房地产')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入疾厄', 4, 8, N'家让我快乐，家庭好，家运顺，生活优渥，不承担家计 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入迁移', 4, 7, N'家世门风好，社会有地位，多外出，衣锦还乡，发富（偏财星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入交友', 4, 6, N'家里朋友客人员工多，人气高，可做人潮生意，物质支出方便')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入事业', 4, 5, N'家里帮助工作，不用负担的工作，易从事和家有关的工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入福德', 4, 3, N'家让我心满意足，家运好，祖上积德，家宅安宁和乐 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅禄入父母', 4, 2, N'家和孝顺，家处市区，人气旺，房子越弄越漂亮，从事老人行业')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'田宅自化禄', 4, 4, N'家看上去不错，里面有点松散，少用心在家，对家不大管')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入命', 3, 1, N'我乐观，想的开，逍遥自在，福报好 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入兄弟', 3, 12, N'不计较兄弟，没有兄弟代表健康经济好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入夫妻', 3, 11, N'对异性格外温柔多情，格外包容溺爱，防桃花（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入子女', 3, 10, N'格外宠小孩，喜欢小孩的天真，喜欢宠物，仁慈善良')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入财帛', 3, 9, N'福厚来财，以兴趣才华赚钱，八方来财，衣食无忧 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入疾厄', 3, 8, N'关心自己身体，心宽体胖，懒散，怕流汗，防心无大志')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入迁移', 3, 7, N'沉醉外面新鲜世界，很感性，流连往返，胸无大志')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入交友', 3, 6, N'喜欢和朋友在一起热闹，有乐同享，乐观，以兴趣会友')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入事业', 3, 5, N'喜欢工作，容易做自己喜好、才华的工作，不积极也能做好 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入田宅', 3, 4, N'祖德流芳，庇荫子孙，家庭生活优渥，也是懒，逍遥')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德禄入父母', 3, 2, N'亲近长辈，和言悦色，有礼貌，爱读书，长辈有祖荫庇护')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'福德自化禄', 3, 3, N'想法天真烂漫，逍遥，没有人生计划，被忌劫，容易被人骗')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入命', 2, 1, N'父母疼爱我，我有忘年交，学习好考试好，见多识广，利公职')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入兄弟', 2, 12, N'父母帮我经济，父母生活安定祥和，与银行多往来，信用好')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入夫妻', 2, 11, N'名正言顺的婚姻，长辈促成婚姻，长辈开明，婚后可与父母同住')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入子女', 2, 10, N'父母疼孩子，祖孙疼，用好的知识教育子女，孩子遇到好老师')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入财帛', 2, 9, N'父母帮我经济，我信用好，多与银行往来，借贷容易')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入疾厄', 2, 8, N'父母关心我身体，可长久同住，我修养好，自在放下')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入迁移', 2, 7, N'父母让我脸上有光，得长辈庇荫，形象好，善表达，利公职')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入交友', 2, 6, N'容易交到有涵养有学识的朋友，有忘年交，父母开明人际好 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入事业', 2, 5, N'父母、政府、上司照顾我工作，高学历带来好工作，利考试 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入田宅', 2, 4, N'父母帮我置产，贷款方便，父母生活安定祥和')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母禄入福德', 2, 3, N'父母让我开心，我与父母关系好，读书缘好，利公职 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (1, N'父母自化禄', 2, 2, N'愉悦喜欢讨好，防伪善。对父母常说好话，少真孝养。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命宫有生年忌', NULL, 1, N'1 命代表我性格，固执，多烦恼，多焦虑，嗔癫痴，早就预设立场，别人不好接 触，如果是贪狼、廉贞这种星，还容易执着于烟酒赌色。 
2 因为性格不好，人生容易出现颠簸，人在红尘就不顺利，命代表你红尘混日子。 
3 影响朋友、婚姻、子女的亲密感，可能容易导致自闭孤独无助。 
4 冲迁移，外出也会因为固执不随缘而惹是生非。
尤其文 昌、文曲、天机忌的，都是有点神经质的固执，是很吓人的。如果巨门忌，更是 可能有猜忌多疑的问题，甚至有人会怀疑被跟踪。。。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟宫生年忌', NULL, 12, N'1 传统保守，守成，在乎成就，有想创业感。 
2 冲交友，对朋友不多情，内敛，不喜应酬，不大方，也容易把人分三六九等看 待，有点自私。 
3 重视兄弟，但兄弟帮助不多。 
4 事必躬亲，容易忙。 
5 兄弟宫是闺房位，容易床上一个人，孤独，分居。 
6 兄弟是身体气数位，气虚，精气神差。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻宫生年忌', NULL, 11, N'1 容易遇人不淑，遇到品质不太好的人，或则遇到固执，不能讲通的人。 
2 代表配偶固执，让我多烦恼，婚姻需要忍耐。 
3 如果有婚外情容易被抓，如果想离婚也难，需要还清婚姻债才行，没有结婚， 也有感情债，也不顺利。 
4 冲事业，容易工作老换，甚至没工作了。容易做上分淡旺季的，或者一个项目 一个项目，计件的工作。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女生年忌', NULL, 10, N'1 子女固执，让我不得不多付出，小辈缘不好，亲戚也少或者关系差。 
2 冲田宅，容易花钱，破财，搬家，老外出不能回家，子女也是意外。 
3 子女也是合伙位，合伙很费心，容易出问题。 
4 子女也是性的宫位，性生活差。女性需要注意子宫的问题。 
5 子女还是婚外情的宫位，也要小心桃花惹祸，尤其是廉贞贪狼这种桃花星。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛生年忌', NULL, 9, N'1 爱财，爱算计，有金钱概念，不大方。财帛生年忌不一定穷。 
2 适合固定薪金的工作，自己赚钱很辛苦，冲福德，为想赚钱感到很头疼，赚多少都不觉得够，福气就少了。 
3 财帛也是夫妻的夫妻，婚姻对待位，所以，容易彼此对待不好，也可能是钱的问题，贫贱夫妻百事哀。 
4 穿着也常邋遢。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄生年忌', NULL, 8, N'1 疾厄代表身体情绪，容易身体不好，多病，情绪也不好。 
2 劳碌，闲不住，内敛。自我情绪很严重。别人不好接触，有点自私。 
3 疾厄也代表家运，家里也容易有不好的事情 。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移生年忌', NULL, 7, N'1 耿直，说话直，憨厚，笨拙，不讨好，不善于察言观色，社会容身之地少。 
2 心机不多，适合简单生活，复杂的生活过不了，没那么多心眼。 
3 离家在外发展常不顺利。 
4 没有赌运，迁移父母见忌的人，不适合生意。也不容易当官，不讨好。 
5 迁移也代表老运，如果有好运要惜福，不要到老全赔出去。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友生年忌', NULL, 6, N'1 常遇到损友、损同事、损客户，困难时候不能帮，好的时候来害你。交友代表 同辈：朋友、同事、客户，有缘遇到的同龄人。 
2 冲兄弟，经济位，理财不好，容易花钱破财。 
3 不利于当官，竞争，考试。当官很多人际水涨船高的，所以交友有禄的人，容易混职位。 
4 要注意自己体质，也要注意配偶的健康问题。 
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业生年忌', NULL, 5, N'1 工作忙，压力大，工作命，一辈子都不会少工作，失业都不容易。 
2 冲夫妻，常晚婚，或者顾不上恋爱，或者容易分手多波折。 
3 事业也是婚姻的迁移，如果贪狼忌，廉贞忌，也要小心烂婚外情。 
4 读书考试成绩可能普通，容易不顺利。 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅生年忌', NULL, 4, N'1 有家庭债，家庭生活不顺利，你想摆脱都不容易，想当和尚出家？基本没门 
2 保守，内敛，顾家，对朋友不多情，少人际往来，也是有点自私的。 
3 田宅也是最大的库位，存在库小，经济有压力，凡是需要白手起家，没有一下 子就发达的运气。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德生年忌', NULL, 3, N'1 福德是一个人的精神层面，和命宫生年忌比较相似，但是可能更严重。偏执， 沉迷所好，不能自拔。如果廉贞贪狼忌，会有烟酒赌色的问题， 
2 精神压力大，有福也难享受。悲观，凡是容易往坏想，常有抑郁情绪，尤其女 性，常杞人忧天。天机，文昌文曲这些星比较明显，如果巨门太阴化忌，还可能 猜忌多疑，或者心里就想偏了。 
3 冲财帛，重享受敢花钱，或者一动念就辞职，把财路冲了。 
4 福德也是一个果报，因果的宫位。如果有忌，你就多修佛，积德行善吧。很多 福德有忌的人，确实也学习佛法，山医命相卜来安顿自己的心。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母生年忌', NULL, 2, N'1 父亲容易固执，和父亲缘分不好，和长辈、领导缘都不好，老得变工作。 
2 自己喜怒形于色，脾气快而大，得罪人，让别人受折磨，自己健康也受损。 
3 读书也不容易轻松，读书方面不够聪慧。 
4 与人金钱往来不顺利，容易被欠债倒账。 
5 迁移父母见忌的人，都存在耿直，不欺骗的特点，所以也不容易做生意。
')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入兄弟', 1, 12, N'在乎兄弟，想创业，重视成就，冲交友，把人分三六九等对待')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入夫妻', 1, 11, N'在乎感情，把异性视作第一位，冲事业，动感情，工作就不稳')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入子女', 1, 10, N'疼孩子，常离家在外，开创性，冲田宅，破财搬家，桃花星是性')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入财帛', 1, 9, N'爱财，认真赚钱，计较钱，冲福德，为赚钱而享受少 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入疾厄', 1, 8, N'容易生病，忙碌，容易自我情绪多，不好接触，有私心')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入迁移', 1, 7, N'耿直，简单，不太有心机，喜欢外出')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入交友', 1, 6, N'惜情重义，把朋友摆第一，冲兄弟，讲情义就花钱，不存钱之忌')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入事业', 1, 5, N'认真工作，事必躬亲，冲夫妻，顾不了配偶，先立业再结婚的想法')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入田宅', 1, 4, N'顾家，保守，有私心，对朋友不多情 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入福德', 1, 3, N'重享受，固执，贪狼廉贞还会有烟酒赌情的瘾，冲财帛，乱花钱')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命忌入父母', 1, 2, N'孝顺，喜怒形于色，脾气大，冲疾厄，脾气伤身，也容易换工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'命自化忌', 1, 1, N'不坚持半途而废，不记恨，过了就算了，情绪反复多变')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入命', 12, 1, N'有经济压力，为兄弟所累，生活宜保守，开源节流 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入夫妻', 12, 11, N'婚后宜单独居住，夫妻少趣。投资少利宜稳定，健康下滑')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入子女', 12, 10, N'退财，财不入库，不善理财，人生多波折。兄弟各立门户')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入财帛', 12, 9, N'退财，支出多，或投资破财，最好有固定来源，健康下滑')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入疾厄', 12, 8, N'兄弟有私心或者我为兄弟所累，我工作忙碌不得闲')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入迁移', 12, 7, N'支出过大，损失比较多，最宜有稳定来源，不要从事生产行业')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入交友', 12, 6, N'退财，借钱给人难收回，不善理财，人生多波折。健康下滑')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入事业', 12, 5, N'兄弟认真工作，适合安定上班，小本生意，宜保守安定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入田宅', 12, 4, N'兄弟顾家自私，对我助力不大。储蓄而积累，辛苦起家')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入福德', 12, 3, N'难蓄财，经济堪忧，健康下滑，兄弟中有重享受之人')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟忌入父母', 12, 2, N'退财，有贷款压力，借钱给人难收回，兄弟孝顺父母 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'兄弟自化忌', 12, 12, N'不善存钱理财，财库漏掉，流失。健康下滑，兄弟助力不大 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入命', 11, 1, N'遇到异性固执，不好讲通，让我不得不多付出，欠感情债')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入兄弟', 11, 12, N'配偶在乎成就，闺房少趣，婚姻倦怠 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入子女', 11, 10, N'配偶疼孩子，配偶不愿回家，婚姻容易出现婚外情（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入财帛', 11, 9, N'贫贱夫妻百事哀，彼此对待不好，易为钱或者琐碎小事争吵')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入疾厄', 11, 8, N'配偶勤快，粘着我，也是不让我愉快，忌入疾厄代表有苦味')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入迁移', 11, 7, N'配偶耿直，平淡无趣，自己也不善表达感情，貌合神离')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入交友', 11, 6, N'配偶惜情重义，家庭无趣，配偶干涉我交友')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入事业', 11, 5, N'配偶重视工作，生活无趣。桃花星，婚姻貌合神离')
GO
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入田宅', 11, 4, N'配偶顾家但也容易自私，桃花星桃花败财，别想齐人之福')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入福德', 11, 3, N'欠感情债，为婚姻感情而苦恼，感情带来极大痛苦')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻忌入父母', 11, 2, N'同居无名分，离婚名分消失，婚姻怨形于色')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'夫妻自化忌', 11, 11, N'不善经营婚姻，貌合神离，感情有离心力')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入命', 10, 1, N'欠子债，小孩固执，教养费心。合伙费心 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入兄弟', 10, 12, N'性生活不好，闺房少趣 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入夫妻', 10, 11, N'先孕后婚，子女粘着配偶，防第三者插足（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入财帛', 10, 9, N'小孩爱挣钱，欠小孩金钱债，合伙亏钱，意外破财')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入疾厄', 10, 8, N'小孩子缠着我，性生活不好，合伙不顺，防意外、病痛')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入迁移', 10, 7, N'子女不在身边，合伙缘差，防意外')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入交友', 10, 6, N'防小孩交坏朋友，合伙不顺')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入事业', 10, 5, N'小孩事业心重，合伙不顺 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入田宅', 10, 4, N'格局好，小孩子顾家勤俭，格局不好，小孩子窥探财产 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入福德', 10, 3, N'为子女操心，小孩重享受，合伙亏钱，老来有忧')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女忌入父母', 10, 2, N'子女孝顺，子女喜怒形于色，格局差，子女不受教 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'子女自化忌', 10, 10, N'少用心于子女，子女费心，合伙不顺，烂桃花（桃花星）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入命', 9, 1, N'赚钱辛苦，最好稳定，为钱伤神。贪狼廉贞，防赌色。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入兄弟', 9, 12, N'储蓄，存钱，积少成多，保守安定，少社交 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入夫妻', 9, 11, N'彼此对待不好，最好分别理财，收入可能不稳定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入子女', 9, 10, N'财不入库，不善理财。给子女多花费')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入疾厄', 9, 8, N'勤快，俭朴，钱花在刀刃上不浪费，保守安定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入迁移', 9, 7, N'憨直少算计，不善社交赚钱，多支出，没有理财观念 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入交友', 9, 6, N'财帛给朋友花掉，漏财，防因友损财')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入事业', 9, 5, N'最好上班，或者现金生意，不要做生产行业，回收资金不行')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入田宅', 9, 4, N'储蓄，存钱，积少成多，保守安定，少社交')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入福德', 9, 3, N'为自己享受乱花钱，不善理财，可能有瘾（廉贞贪狼）')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛忌入父母', 9, 2, N'支出多，不善理财，防信贷问题，和人金钱往来不顺')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'财帛自化忌', 9, 9, N'手头存不住钱，多花用，宜上班或现金生意 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入命', 8, 1, N'情绪差，不得不忙禄，容易生病 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入兄弟', 8, 12, N'体质欠佳，情绪不开朗，社交少，需多运动')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入夫妻', 8, 11, N'性生活差，体质瘦弱 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入子女', 8, 10, N'不喜欢小孩缠我，性生活不好，不耐静，个性不稳 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入财帛', 8, 9, N'玩命过劳的挣钱，或者身体差花医药费 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入迁移', 8, 7, N'性燥，遇事乱章法，瘦，防意外和病。外出不安定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入交友', 8, 6, N'不喜欢久腻朋友，不热络，健康下滑，夫妻闺房不合')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入事业', 8, 5, N'工作环境差，工作超负荷，不开心，瘦')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入田宅', 8, 4, N'情绪不开朗，宅男宅女，容易得病，家运凝滞 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入福德', 8, 3, N'情绪不好，生活压力大，久病')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄忌入父母', 8, 2, N'脾气快，心直口快，喜怒形于色')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'疾厄自化忌', 8, 8, N'劳碌，情绪不稳，自我情绪比较严重，生病还容易摘除器官 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入命', 7, 1, N'孤独，不善逢迎，意外的天灾人祸，防小人，宜保守谨慎，会有自闭的个性、少了点自信 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入兄弟', 7, 12, N'社会关系差，不会逢迎，影响成就，不会理财，意外破财，还可能不会应付妈妈、兄弟')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入夫妻', 7, 11, N'不善处理异性的事情，第三者插足我婚姻，意外影响工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入子女', 7, 10, N'不善应付小孩子和人际，外出劳而无功，理财越理越乱')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入财帛', 7, 9, N'不善理财，财路窄，防意外损财，防小人')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入疾厄', 7, 8, N'意外伤害身体，奔波劳碌危险，意外小人纠缠，业力病 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入交友', 7, 6, N'不会处理人际问题，喜清静，不喜欢交往，单纯')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入事业', 7, 5, N'不善逢迎，工作面窄，老实工作，防小人，意外伤害工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入田宅', 7, 4, N'家道不兴，门庭冷落，背井离乡，意外损财，被盗窃，不会处理家庭关系或财产房子的问题导致损财')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入福德', 7, 3, N'外在对精神情绪影响大，意外灾病 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移忌入父母', 7, 2, N'不善处理长辈人际，孤陋寡闻，不善社会学习，不善察言观色')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'迁移自化忌', 7, 7, N'不喜逢迎，不在意外面对自己看法，却少社会智慧')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入命', 6, 1, N'欠朋友债，遇小人，为人际多付出。不利于竞争')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入兄弟', 6, 12, N'损友窥视我财务，防引狼入室，被经济差的朋友拖垮')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入夫妻', 6, 11, N'夫妻生活无味，配偶身体又恙，第三者插足我婚姻')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入子女', 6, 10, N'性方面被占便宜（桃花星），防小孩学坏，合伙不顺 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入财帛', 6, 9, N'防爱财的朋友，被人家盯上，或者穷困的朋友')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入疾厄', 6, 8, N'怕孤独乱交朋友，狐朋狗友，小人纠缠，树倒猢孙散')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入迁移', 6, 7, N'交际少，朋友不多，好朋友在远方，近身多是要累心的人际')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入事业', 6, 5, N'工作上容易遇小人，合伙尤其要防止舞弊。不利于竞争 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入田宅', 6, 4, N'损友鲸吞我钱财，是非，被人偷窃盯梢')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入福德', 6, 3, N'孤僻，只能交同嗜好的朋友，朋友重享受，最终还是孤独 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友忌入父母', 6, 2, N'格局好，朋友爱读书孝顺，格局不好，朋友叛逆素质低')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'交友自化忌', 6, 6, N'交友不长久，不喜欢逢迎，终究也没知己')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入命', 5, 1, N'有工作债，为工作忙死，不得不做 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入兄弟', 5, 12, N'守成稳定常公职，忙碌事必躬亲，冲交友，社交不多 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入夫妻', 5, 11, N'工作不稳定，创业需和配偶共同努力，防自身桃花破坏婚姻')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入子女', 5, 10, N'合伙费心，工作不稳定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入财帛', 5, 9, N'宜稳定上班，只适合现金生意，不适合生产行业，资金难周转')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入疾厄', 5, 8, N'工作劳碌，紧张，身体倦怠，无人可替，事必躬亲，少社交')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入迁移', 5, 7, N'不善攀缘，应酬，际遇差，工作停顿，宜稳定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入交友', 5, 6, N'最好独立工作，否则损友拖垮，不宜合伙 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入田宅', 5, 4, N'守成稳定常公职，或者和家人一起做，社交不多')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入福德', 5, 3, N'工作心烦，最好做自己有兴趣的，事业不挣钱，宜稳定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业忌入父母', 5, 2, N'不善和领导相处，不利公职，容易工作不稳定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'事业自化忌', 5, 5, N'宜稳定上班，只适合现金生意，对工作不坚持')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入命', 4, 1, N'有家庭或经济负担，需要为家多付出，容易担负长子责任')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入兄弟', 4, 12, N'退财，投资容易负债，兄弟承担家计，宜店家分开')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入夫妻', 4, 11, N'配偶承担家计，婚后小家庭单独住，夫妻相处宜少，少投机')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入子女', 4, 10, N'大笔花钱，退财，家庭离心力，孩子需承担家计')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入财帛', 4, 9, N'退财，耗材，不存钱，容易负债，防贷款压力，宜保守')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入疾厄', 4, 8, N'有家庭债，需承担家计，家庭纷扰，在家呆不住')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入迁移', 4, 7, N'搬家退财，家道不兴，房子旧或偏远，背井离乡')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入交友', 4, 6, N'退财破财，家偏远，家庭人气不旺 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入事业', 4, 5, N'有家庭负担要不停工作，宜店家分开，小本经营')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入福德', 4, 3, N'家让我烦，家宅不宁，家道不兴')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅忌入父母', 4, 2, N'搬家退财，家偏远，拖贷款，不能帮人作保，门风差')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'田宅自化忌', 4, 4, N'耗材，退产，家庭凝聚力差，不顾家，多搬家')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入命', 3, 1, N'杞人忧天，多烦恼。遇贪狼廉贞，还有瘾，导致人生波折。')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入兄弟', 3, 12, N'自私，执着于成就，为人计较不多情，健康有碍')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入夫妻', 3, 11, N'偏执的爱，爱恨激烈，执迷感情，桃花临身毁掉婚姻 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入子女', 3, 10, N'操心子女，对子女挑剔，溺爱，不听话又会严厉管教')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入财帛', 3, 9, N'爱财，精打细算，为钱伤神，伤福气，偏执狭隘')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入疾厄', 3, 8, N'有洁癖（太阴）或者偏执，焦虑，自残。情绪差')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入迁移', 3, 7, N'偏执暴躁，脾气大，不惜福，防灾病，修行者（遇宗教星） ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入交友', 3, 6, N'怕孤独而非理性人际交往。逢宗教星，容易布施众人')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入事业', 3, 5, N'偏执狭隘，挑剔工作，最好以兴趣为业，有技能最好。
挑剔工作，没工作就必须工作，有工作必须换工作')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入田宅', 3, 4, N'自私狭隘，顾家，对亲戚朋友不多情，最宜修身养性 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德忌入父母', 3, 2, N'偏激暴躁，脾气大，出言不逊向外发泄，修养差，挑剔长辈')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'福德自化忌', 3, 3, N'常有莫名烦恼，耐性不足，好恶善变')
GO
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入命', 2, 1, N'父母疼我')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入兄弟', 2, 12, N'父母守成，父母关心兄弟，有银行贷款，不要帮人作保')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入夫妻', 2, 11, N'长辈烦恼反对我婚姻，违反道德的婚姻，父母道德位')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入子女', 2, 10, N'父母疼孩子，我对小孩子教育不得要领')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入财帛', 2, 9, N'父母勤俭，父母担心我金钱，小心贷款作保与人金钱往来不顺')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入疾厄', 2, 8, N'父母忙碌，父母管我过多，我不爱念书，修养差')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入迁移', 2, 7, N'父母不能庇荫我或者远离我，表达差，出口成脏，不利于念书')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入交友', 2, 6, N'父母重义，我考试竞争不利，长辈干涉我人际，忠言谏友')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入事业', 2, 5, N'父母重工作，父母担心我工作，长辈给我工作施压，念书辛苦')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入田宅', 2, 4, N'父母顾家，父母担心我家庭，有银行贷款，格局不好家门风差')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母忌入福德', 2, 3, N'不爱念书，父母有忧，不宜与人有金钱往来')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (4, N'父母自化忌', 2, 2, N'不喜欢念书，不虚心，少形象气质，不关心长辈，需尽孝养之责')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在命', NULL, 1, N'有能力，自信，主见，自以为是')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在兄弟', NULL, 12, N'兄弟能干，妈妈能力强，我事业金钱有成，精气神强')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在夫妻', NULL, 11, N'配偶有主见，防争执。权照事业 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在子女', NULL, 10, N'孩子有主见，不好管。合伙有成')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在财帛', NULL, 9, N'挣钱积极，业务开拓能力强，收入好，适合分红薪水')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在疾厄', NULL, 8, N'身体结实，硬朗，有活力多动，防跌撞')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在迁移', NULL, 7, N'果断，积极，领导，有社会地位，防自负')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在交友', NULL, 6, N'朋友能力好，客户强大，棋逢对手遇到强势竞争者')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在事业', NULL, 5, N'积极，拓展事业，能力好，收入高，最好有专业')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在田宅', NULL, 4, N'家世好，家旺，有活力，自己也容易财库大，不动产值钱')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在福德', NULL, 3, N'自以为是，高傲，喜欢高品质高格调，爱面子')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'生年权在父母', NULL, 2, N'父母有主见，本人强势，得理不饶人，容易有专业技能 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在命', NULL, 1, N'斯文，秀气，讲理，温和')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在兄弟', NULL, 12, N'兄弟文气好商量，理财有计划，经济稳定')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在夫妻', NULL, 11, N'配偶文气好商量，容易有藕断丝连的感情')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在子女', NULL, 10, N'孩子温和懂事，乖巧')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在财帛', NULL, 9, N'适合上班，收入不高，但源源不断，小额周转')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在疾厄', NULL, 8, N'举止斯文，有病得良医')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在迁移', NULL, 7, N'文质彬彬，形象好，有名声')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在交友', NULL, 6, N'朋友多谦和，君子之交 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在事业', NULL, 5, N'工作平稳适合文职，有贵人，多思虑 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在田宅', NULL, 4, N'房子不大，朴实，家有书香，生活恬淡')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在福德', NULL, 3, N'淡，平和，不虚华，思维精致，有内涵品味')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'生年科在父母', NULL, 2, N'父母谦和，个人斯文有气质，容易学业有名气 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命自化权', 1, 1, N'自以为是，但是纸老虎，吓唬人的')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入兄弟', 1, 12, N'兄弟中占权，朋友里也把自己当领导，创业企图心很强')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入夫妻', 1, 11, N'对配偶有支配欲，配偶去哪都要知道')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入子女', 1, 10, N'对子女强势，管教严格，合作容易掌权')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入财帛', 1, 9, N'积极的挣钱，开拓广泛财源')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入疾厄', 1, 8, N'粗线条，积极，抗压，适合运动')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入迁移', 1, 7, N'我要向外拓展，能干，果断，但也自负霸气，容易惹事')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入交友', 1, 6, N'自视甚高，喜欢替人出头，帮人摆不平，很爱管闲事')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入事业', 1, 5, N'积极开拓工作，对事业有企图心，对配偶也强势')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入田宅', 1, 4, N'家庭里占权，对子女管教严厉，财富企图心很强')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入福德', 1, 3, N'自以为是，很主观，喜欢排场，爱面子，喜欢奢侈品 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (2, N'命权入父母', 1, 2, N'父母形于外的宫位，强势，得理不饶人，鲁莽傲慢，得罪人 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命自化科', 1, 1, N'斯文，秀气，讲理，多犹豫')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入兄弟', 1, 12, N'与兄弟好商量，喜欢稳妥的花钱')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入夫妻', 1, 11, N'对配偶温和，好商量，感情细腻悠长')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入子女', 1, 10, N'对子女讲道理，民主，好商量，开明的教育方式')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入财帛', 1, 9, N'对金钱不大有企图，喜欢平稳的进财，上班安稳最好 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入疾厄', 1, 8, N'不胖不瘦，举止优雅 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入迁移', 1, 7, N'外面处世平和，文雅，防优柔寡断')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入交友', 1, 6, N'君子之交淡入水，但友情悠远 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入事业', 1, 5, N'喜欢平稳工作，魄力不足，适合文职。防遇事多思多虑')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入田宅', 1, 4, N'喜欢大小适中的房屋，温和朴实的家庭生活')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入福德', 1, 3, N'恬淡，安逸，不虚荣 ')
INSERT [dbo].[wFeiXing] ([FeiXingTypeId], [FeiXing], [FromGongWeiID], [ToGongWeiID], [Note]) VALUES (3, N'命科入父母', 1, 2, N'平和，文质彬彬，谈吐斯文')
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (1, 1, 1, 6)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (2, 1, 2, 14)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (3, 1, 3, 4)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (4, 1, 4, 3)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (5, 2, 1, 2)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (6, 2, 2, 12)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (7, 2, 3, 1)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (8, 2, 4, 8)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (9, 3, 1, 5)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (10, 3, 2, 2)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (11, 3, 3, 23)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (12, 3, 4, 6)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (13, 4, 1, 8)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (14, 4, 2, 5)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (15, 4, 3, 2)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (16, 4, 4, 10)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (17, 5, 1, 9)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (18, 5, 2, 8)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (19, 5, 3, 3)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (20, 5, 4, 2)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (21, 6, 1, 4)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (22, 6, 2, 9)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (23, 6, 3, 12)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (24, 6, 4, 24)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (25, 7, 1, 3)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (26, 7, 2, 4)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (27, 7, 3, 7)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (28, 7, 4, 5)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (29, 8, 1, 10)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (30, 8, 2, 3)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (31, 8, 3, 24)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (32, 8, 4, 23)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (33, 9, 1, 12)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (34, 9, 2, 1)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (35, 9, 3, 7)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (36, 9, 4, 4)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (37, 10, 1, 14)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (38, 10, 2, 10)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (39, 10, 3, 8)
INSERT [dbo].[wGanSiHua] ([GanSiHuaId], [GanId], [SiHuaId], [XingYaoId]) VALUES (40, 10, 4, 9)
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (1, N'庙')
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (2, N'旺')
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (3, N'得地')
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (4, N'利益')
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (5, N'平和')
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (6, N'不得地')
INSERT [dbo].[wMiaoXian] ([MiaoXianId], [MiaoXian]) VALUES (7, N'落陷')
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 1, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 4, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 5, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 6, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 7, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 8, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 9, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 10, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 11, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (1, 12, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 1, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 2, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 3, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 4, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 6, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 7, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 8, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 9, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 10, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 11, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (2, 12, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 1, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 2, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 3, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 4, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 6, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 7, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 8, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 9, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 10, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 11, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (3, 12, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 1, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 3, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 4, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 5, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 6, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 7, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 8, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 9, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 10, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 11, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (4, 12, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 1, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 2, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 3, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 4, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 5, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 6, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 7, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 8, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 9, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 10, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 11, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (5, 12, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 1, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 2, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 4, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 6, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 7, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 8, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 9, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 10, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 11, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (6, 12, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 1, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 4, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 5, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 6, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 7, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 8, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 9, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 10, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 11, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (7, 12, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 1, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 3, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 4, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 5, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 6, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 7, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 8, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 9, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 10, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 11, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (8, 12, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 1, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 3, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 4, 3)
GO
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 5, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 6, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 7, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 8, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 9, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 10, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 11, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (9, 12, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 1, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 2, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 4, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 5, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 6, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 7, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 8, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 9, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 10, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 11, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (10, 12, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 1, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 4, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 6, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 7, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 8, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 9, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 10, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 11, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (11, 12, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 1, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 2, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 4, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 6, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 7, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 8, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 9, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 10, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 11, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (12, 12, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 1, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 2, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 3, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 4, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 6, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 7, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 8, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 9, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 10, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 11, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (13, 12, 3)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 1, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 2, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 3, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 4, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 5, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 6, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 7, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 8, 1)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 9, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 10, 4)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 11, 2)
INSERT [dbo].[wMiaoXianGX] ([XingYaoId], [ZhiId], [MiaoXianId]) VALUES (14, 12, 3)
INSERT [dbo].[wSiHua] ([SiHuaId], [SiHua]) VALUES (1, N'禄')
INSERT [dbo].[wSiHua] ([SiHuaId], [SiHua]) VALUES (2, N'权')
INSERT [dbo].[wSiHua] ([SiHuaId], [SiHua]) VALUES (3, N'科')
INSERT [dbo].[wSiHua] ([SiHuaId], [SiHua]) VALUES (4, N'忌')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (1, 1, N'紫薇')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (2, 1, N'天机')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (3, 1, N'太阳')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (4, 1, N'武曲')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (5, 1, N'天同')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (6, 1, N'廉贞')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (7, 1, N'天府')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (8, 1, N'太阴')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (9, 1, N'贪狼')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (10, 1, N'巨门')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (11, 1, N'天相')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (12, 1, N'天梁')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (13, 1, N'七杀')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (14, 1, N'破军')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (15, 2, N'火星')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (16, 2, N'铃星')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (17, 2, N'擎羊')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (18, 2, N'陀罗')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (19, 3, N'左辅')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (20, 3, N'右弼')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (21, 3, N'天魁')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (22, 3, N'天钺')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (23, 3, N'文昌')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (24, 3, N'文曲')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (25, 3, N'禄存')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (26, 3, N'天马')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (27, 4, N'地劫')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (28, 4, N'地空')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (29, 4, N'龙池')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (30, 4, N'凤阁')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (31, 4, N'天哭')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (32, 4, N'天虚')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (33, 4, N'红鸾')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (34, 4, N'天喜')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (35, 4, N'孤辰')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (36, 4, N'寡宿')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (37, 4, N'天德')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (38, 4, N'月德')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (39, 4, N'华盖')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (40, 4, N'天才')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (41, 4, N'天寿')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (42, 4, N'破碎')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (43, 4, N'咸池')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (44, 4, N'大耗')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (45, 4, N'蜚廉')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (46, 4, N'天空')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (47, 4, N'旬空')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (48, 4, N'截空')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (49, 4, N'天厨')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (50, 4, N'天月')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (51, 4, N'天刑')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (52, 4, N'天姚')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (53, 4, N'天巫')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (54, 4, N'解神')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (55, 4, N'阴煞')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (56, 4, N'台辅')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (57, 4, N'封诰')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (58, 4, N'三台')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (59, 4, N'八座')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (60, 4, N'恩光')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (61, 4, N'天贵')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (62, 4, N'天官')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (63, 4, N'天福')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (64, 4, N'龙德')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (65, 4, N'年德')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (66, 5, N'长生')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (67, 5, N'沐浴')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (68, 5, N'冠带')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (69, 5, N'临官')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (70, 5, N'帝旺')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (71, 5, N'衰')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (72, 5, N'病')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (73, 5, N'死')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (74, 5, N'墓')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (75, 5, N'绝')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (76, 5, N'胎')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (77, 5, N'养')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (78, 6, N'太岁')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (79, 6, N'晦气')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (80, 6, N'丧门')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (81, 6, N'贯索')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (82, 6, N'官府')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (83, 6, N'小耗')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (84, 6, N'岁破')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (85, 6, N'龙德')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (86, 6, N'白虎')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (87, 6, N'天德')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (88, 6, N'吊客')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (89, 6, N'病符')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (90, 7, N'将星')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (91, 7, N'攀鞍')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (92, 7, N'岁驿')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (93, 7, N'息神')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (94, 7, N'华盖')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (95, 7, N'劫煞')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (96, 7, N'灾煞')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (97, 7, N'天煞')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (98, 7, N'指背')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (99, 7, N'咸池')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (100, 7, N'月煞')
GO
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (101, 7, N'亡神')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (102, 8, N'博士')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (103, 8, N'力士')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (104, 8, N'青龙')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (105, 8, N'小耗')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (106, 8, N'将军')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (107, 8, N'奏书')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (108, 8, N'飞廉')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (109, 8, N'喜神')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (110, 8, N'病符')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (111, 8, N'大耗')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (112, 8, N'伏兵')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (113, 8, N'官府')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (114, 9, N'流昌')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (115, 9, N'流曲')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (116, 4, N'劫煞')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (117, 4, N'天伤')
INSERT [dbo].[wXingYao] ([XingYaoId], [XingYaoTypeId], [XingYao]) VALUES (118, 4, N'天使')
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (1, N'甲', 1, 1, 1, 1, 1, 1)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (2, N'乙', 2, 1, 1, 1, 2, 2)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (3, N'丙', 1, 2, 2, 2, 3, 3)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (4, N'丁', 2, 2, 2, 2, 4, 4)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (5, N'戊', 1, 3, 5, 5, 5, 5)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (6, N'己', 2, 3, 5, 5, 5, 6)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (7, N'庚', 1, 4, 3, 3, 6, 7)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (8, N'辛', 2, 4, 3, 3, 6, 8)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (9, N'壬', 1, 5, 4, 4, 8, 9)
INSERT [dbo].[zGan] ([GanId], [Gan], [YingYangId], [WuHangId], [JiJieId], [FangWeiId], [TiBiaoId], [ZangFuId]) VALUES (10, N'癸', 2, 5, 4, 4, 9, 10)
SET IDENTITY_INSERT [dbo].[zGanZhiGX] ON 

INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (1, 2, 1, 2, NULL, 1, 3, N'子丑合土')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (2, 2, 3, 12, NULL, 1, 1, N'寅亥合木')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (3, 2, 4, 11, NULL, 1, 2, N'卯戌合火')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (4, 2, 5, 10, NULL, 1, 4, N'辰酉合金')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (5, 2, 6, 9, NULL, 1, 5, N'巳申合水')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (6, 2, 1, 7, NULL, 2, NULL, N'子午相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (7, 2, 2, 8, NULL, 2, NULL, N'丑未相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (8, 2, 3, 9, NULL, 2, NULL, N'寅申相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (9, 2, 4, 10, NULL, 2, NULL, N'卯酉相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (10, 2, 5, 11, NULL, 2, NULL, N'辰戌相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (11, 2, 6, 12, NULL, 2, NULL, N'巳亥相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (12, 2, 1, 8, NULL, 5, NULL, N'子未相害')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (13, 2, 2, 7, NULL, 5, NULL, N'丑午相害')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (14, 2, 4, 5, NULL, 5, NULL, N'卯辰相害')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (15, 2, 3, 6, NULL, 5, NULL, N'寅巳相害')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (16, 2, 9, 12, NULL, 5, NULL, N'申亥相害')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (17, 2, 10, 11, NULL, 5, NULL, N'酉戌相害')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (18, 2, 9, 1, 5, 3, 5, N'申子辰三合水局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (19, 2, 6, 10, 2, 3, 4, N'巳酉丑三合金局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (20, 2, 3, 7, 11, 3, 2, N'寅午戌三合火局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (21, 2, 12, 4, 8, 3, 1, N'亥卯未三合木局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (22, 2, 3, 4, 5, 4, 1, N'寅卯辰三会东方木')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (23, 2, 6, 7, 8, 4, 2, N'巳午未三会南方火')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (24, 2, 9, 10, 11, 4, 4, N'申酉戌三会西方金')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (25, 2, 12, 1, 2, 4, 5, N'亥子丑三会北方水')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (26, 2, 1, 2, NULL, 6, NULL, N'无礼之刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (27, 2, 3, 6, 9, 6, NULL, N'恃势之刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (28, 2, 2, 11, 8, 6, NULL, N'无恩之刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (29, 2, 5, 5, NULL, 6, NULL, N'辰辰自刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (30, 2, 7, 7, NULL, 6, NULL, N'午午自刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (31, 2, 10, 10, NULL, 6, NULL, N'酉酉自刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (32, 2, 12, 12, NULL, 6, NULL, N'亥亥自刑')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (33, 2, 3, 7, NULL, 7, NULL, N'寅午生地半合火局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (34, 2, 7, 11, NULL, 7, NULL, N'午戌墓地半合火局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (35, 2, 12, 4, NULL, 7, NULL, N'亥卯生地半合木局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (36, 2, 4, 8, NULL, 7, NULL, N'卯未墓地半合木局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (37, 2, 9, 1, NULL, 7, NULL, N'申子生地半合水局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (38, 2, 1, 5, NULL, 7, NULL, N'子辰墓地半合水局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (39, 2, 6, 10, NULL, 7, NULL, N'巳酉生地半合金局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (40, 2, 10, 2, NULL, 7, NULL, N'酉丑墓地半合金局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (41, 2, 3, 11, NULL, 8, NULL, N'寅戌拱合火局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (42, 2, 12, 8, NULL, 8, NULL, N'亥未拱合木局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (43, 2, 9, 5, NULL, 8, NULL, N'申辰拱合水局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (44, 2, 6, 2, NULL, 8, NULL, N'巳丑拱合金局')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (45, 1, 1, 6, NULL, 1, 3, N'甲己合化土,为中正之合')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (46, 1, 2, 7, NULL, 1, 4, N'乙庚合化金,为仁义之合')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (47, 1, 3, 8, NULL, 1, 5, N'丙辛合化水,为威制之合')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (48, 1, 4, 9, NULL, 1, 1, N'丁壬合化木,为仁寿之合')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (49, 1, 5, 10, NULL, 1, 2, N'戊癸合化火,为无情之合')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (50, 1, 1, 7, NULL, 2, NULL, N'甲庚相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (51, 1, 2, 8, NULL, 2, NULL, N'乙辛相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (52, 1, 3, 9, NULL, 2, NULL, N'丙壬相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (53, 1, 4, 10, NULL, 2, NULL, N'丁癸相冲')
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (175, 3, 1, 1, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (176, 3, 1, 2, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (177, 3, 1, 3, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (178, 3, 1, 4, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (179, 3, 1, 5, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (180, 3, 1, 6, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (181, 3, 1, 7, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (182, 3, 1, 8, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (183, 3, 1, 9, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (184, 3, 1, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (185, 3, 2, 1, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (186, 3, 2, 2, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (187, 3, 2, 3, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (188, 3, 2, 4, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (189, 3, 2, 5, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (190, 3, 2, 6, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (191, 3, 2, 7, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (192, 3, 2, 8, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (193, 3, 2, 9, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (194, 3, 2, 10, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (195, 3, 3, 1, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (196, 3, 3, 2, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (197, 3, 3, 3, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (198, 3, 3, 4, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (199, 3, 3, 5, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (200, 3, 3, 6, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (201, 3, 3, 7, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (202, 3, 3, 8, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (203, 3, 3, 9, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (204, 3, 3, 10, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (205, 3, 4, 1, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (206, 3, 4, 2, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (207, 3, 4, 3, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (208, 3, 4, 4, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (209, 3, 4, 5, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (210, 3, 4, 6, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (211, 3, 4, 7, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (212, 3, 4, 8, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (213, 3, 4, 9, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (214, 3, 4, 10, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (215, 3, 5, 1, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (216, 3, 5, 2, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (217, 3, 5, 3, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (218, 3, 5, 4, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (219, 3, 5, 5, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (220, 3, 5, 6, NULL, NULL, 9, NULL)
GO
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (221, 3, 5, 7, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (222, 3, 5, 8, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (223, 3, 5, 9, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (224, 3, 5, 10, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (225, 3, 6, 1, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (226, 3, 6, 2, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (227, 3, 6, 3, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (228, 3, 6, 4, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (229, 3, 6, 5, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (230, 3, 6, 6, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (231, 3, 6, 7, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (232, 3, 6, 8, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (233, 3, 6, 9, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (234, 3, 6, 10, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (235, 3, 7, 1, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (236, 3, 7, 2, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (237, 3, 7, 3, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (238, 3, 7, 4, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (239, 3, 7, 5, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (240, 3, 7, 6, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (241, 3, 7, 7, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (242, 3, 7, 8, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (243, 3, 7, 9, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (244, 3, 7, 10, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (245, 3, 8, 1, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (246, 3, 8, 2, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (247, 3, 8, 3, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (248, 3, 8, 4, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (249, 3, 8, 5, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (250, 3, 8, 6, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (251, 3, 8, 7, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (252, 3, 8, 8, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (253, 3, 8, 9, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (254, 3, 8, 10, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (255, 3, 9, 1, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (256, 3, 9, 2, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (257, 3, 9, 3, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (258, 3, 9, 4, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (259, 3, 9, 5, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (260, 3, 9, 6, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (261, 3, 9, 7, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (262, 3, 9, 8, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (263, 3, 9, 9, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (264, 3, 9, 10, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (265, 3, 10, 1, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (266, 3, 10, 2, NULL, NULL, 4, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (267, 3, 10, 3, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (268, 3, 10, 4, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (269, 3, 10, 5, NULL, NULL, 5, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (270, 3, 10, 6, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (271, 3, 10, 7, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (272, 3, 10, 8, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (273, 3, 10, 9, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (274, 3, 10, 10, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (275, 4, 1, 12, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (276, 4, 1, 1, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (277, 4, 1, 2, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (278, 4, 1, 3, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (279, 4, 1, 4, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (280, 4, 1, 5, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (281, 4, 1, 6, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (282, 4, 1, 7, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (283, 4, 1, 8, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (284, 4, 1, 9, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (285, 4, 1, 10, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (286, 4, 1, 11, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (287, 4, 2, 7, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (288, 4, 2, 6, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (289, 4, 2, 5, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (290, 4, 2, 4, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (291, 4, 2, 3, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (292, 4, 2, 2, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (293, 4, 2, 1, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (294, 4, 2, 12, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (295, 4, 2, 11, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (296, 4, 2, 10, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (297, 4, 2, 9, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (298, 4, 2, 8, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (299, 4, 3, 3, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (300, 4, 3, 4, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (301, 4, 3, 5, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (302, 4, 3, 6, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (303, 4, 3, 7, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (304, 4, 3, 8, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (305, 4, 3, 9, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (306, 4, 3, 10, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (307, 4, 3, 11, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (308, 4, 3, 12, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (309, 4, 3, 1, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (310, 4, 3, 2, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (311, 4, 4, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (312, 4, 4, 9, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (313, 4, 4, 8, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (314, 4, 4, 7, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (315, 4, 4, 6, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (316, 4, 4, 5, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (317, 4, 4, 4, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (318, 4, 4, 3, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (319, 4, 4, 2, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (320, 4, 4, 1, NULL, NULL, 12, NULL)
GO
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (321, 4, 4, 12, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (322, 4, 4, 11, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (323, 4, 5, 3, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (324, 4, 5, 4, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (325, 4, 5, 5, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (326, 4, 5, 6, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (327, 4, 5, 7, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (328, 4, 5, 8, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (329, 4, 5, 9, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (330, 4, 5, 10, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (331, 4, 5, 11, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (332, 4, 5, 12, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (333, 4, 5, 1, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (334, 4, 5, 2, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (335, 4, 6, 10, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (336, 4, 6, 9, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (337, 4, 6, 8, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (338, 4, 6, 7, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (339, 4, 6, 6, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (340, 4, 6, 5, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (341, 4, 6, 4, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (342, 4, 6, 3, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (343, 4, 6, 2, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (344, 4, 6, 1, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (345, 4, 6, 12, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (346, 4, 6, 11, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (347, 4, 7, 6, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (348, 4, 7, 7, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (349, 4, 7, 8, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (350, 4, 7, 9, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (351, 4, 7, 10, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (352, 4, 7, 11, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (353, 4, 7, 12, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (354, 4, 7, 1, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (355, 4, 7, 2, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (356, 4, 7, 3, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (357, 4, 7, 4, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (358, 4, 7, 5, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (359, 4, 8, 1, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (360, 4, 8, 12, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (361, 4, 8, 11, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (362, 4, 8, 10, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (363, 4, 8, 9, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (364, 4, 8, 8, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (365, 4, 8, 7, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (366, 4, 8, 6, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (367, 4, 8, 5, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (368, 4, 8, 4, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (369, 4, 8, 3, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (370, 4, 8, 2, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (371, 4, 9, 9, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (372, 4, 9, 10, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (373, 4, 9, 11, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (374, 4, 9, 12, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (375, 4, 9, 1, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (376, 4, 9, 2, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (377, 4, 9, 3, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (378, 4, 9, 4, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (379, 4, 9, 5, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (380, 4, 9, 6, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (381, 4, 9, 7, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (382, 4, 9, 8, NULL, NULL, 14, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (383, 4, 10, 4, NULL, NULL, 1, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (384, 4, 10, 3, NULL, NULL, 2, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (385, 4, 10, 2, NULL, NULL, 3, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (386, 4, 10, 1, NULL, NULL, 6, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (387, 4, 10, 12, NULL, NULL, 7, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (388, 4, 10, 11, NULL, NULL, 8, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (389, 4, 10, 10, NULL, NULL, 9, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (390, 4, 10, 9, NULL, NULL, 10, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (391, 4, 10, 8, NULL, NULL, 11, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (392, 4, 10, 7, NULL, NULL, 12, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (393, 4, 10, 6, NULL, NULL, 13, NULL)
INSERT [dbo].[zGanZhiGX] ([GXId], [GXTypeId], [GanZhiId1], [GanZhiId2], [GanZhiId3], [GanZhiGXId], [GXValueId], [Remark]) VALUES (394, 4, 10, 5, NULL, NULL, 14, NULL)
SET IDENTITY_INSERT [dbo].[zGanZhiGX] OFF
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (1, 1, 1, 1)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (2, 2, 2, 1)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (3, 3, 3, 2)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (4, 4, 4, 2)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (5, 5, 5, 3)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (6, 6, 6, 3)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (7, 7, 7, 4)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (8, 8, 8, 4)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (9, 9, 9, 5)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (10, 10, 10, 5)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (11, 1, 11, 6)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (12, 2, 12, 6)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (13, 3, 1, 7)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (14, 4, 2, 7)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (15, 5, 3, 8)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (16, 6, 4, 8)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (17, 7, 5, 9)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (18, 8, 6, 9)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (19, 9, 7, 10)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (20, 10, 8, 10)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (21, 1, 9, 11)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (22, 2, 10, 11)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (23, 3, 11, 12)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (24, 4, 12, 12)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (25, 5, 1, 13)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (26, 6, 2, 13)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (27, 7, 3, 14)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (28, 8, 4, 14)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (29, 9, 5, 15)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (30, 10, 6, 15)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (31, 1, 7, 16)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (32, 2, 8, 16)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (33, 3, 9, 17)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (34, 4, 10, 17)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (35, 5, 11, 18)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (36, 6, 12, 18)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (37, 7, 1, 19)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (38, 8, 2, 19)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (39, 9, 3, 20)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (40, 10, 4, 20)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (41, 1, 5, 21)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (42, 2, 6, 21)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (43, 3, 7, 22)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (44, 4, 8, 22)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (45, 5, 9, 23)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (46, 6, 10, 23)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (47, 7, 11, 24)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (48, 8, 12, 24)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (49, 9, 1, 25)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (50, 10, 2, 25)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (51, 1, 3, 30)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (52, 2, 4, 30)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (53, 3, 5, 26)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (54, 4, 6, 26)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (55, 5, 7, 27)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (56, 6, 8, 27)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (57, 7, 9, 28)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (58, 8, 10, 28)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (59, 9, 11, 29)
INSERT [dbo].[zJiaZi] ([JiaZiId], [jiaZiGanId], [JiaZiZhiId], [NaYinId]) VALUES (60, 10, 12, 29)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (1, 12, N'小寒', 2, 0)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (2, 12, N'大寒', 2, 21208)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (3, 1, N'立春', 3, 42467)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (4, 1, N'雨水', 3, 63836)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (5, 2, N'惊蛰', 4, 85337)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (6, 2, N'春分', 4, 107014)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (7, 3, N'清明', 5, 128867)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (8, 3, N'谷雨', 5, 150921)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (9, 4, N'立夏', 6, 173149)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (10, 4, N'小满', 6, 195551)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (11, 5, N'芒种', 7, 218072)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (12, 5, N'夏至', 7, 240693)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (13, 6, N'小暑', 8, 263343)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (14, 6, N'大暑', 8, 285989)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (15, 7, N'立秋', 9, 308563)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (16, 7, N'处暑', 9, 331033)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (17, 8, N'白露', 10, 353350)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (18, 8, N'秋分', 10, 375494)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (19, 9, N'寒露', 11, 397447)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (20, 9, N'霜降', 11, 419210)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (21, 10, N'立冬', 12, 440795)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (22, 10, N'小雪', 12, 462224)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (23, 11, N'大雪', 1, 483532)
INSERT [dbo].[zJieQi] ([JieQiId], [JieQiMonth], [JieQi], [ZhiId], [Minutes]) VALUES (24, 11, N'冬至', 1, 504758)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianKui', NULL, N'天魁', 0, 1, 5, 7, NULL, 2, NULL, NULL, NULL, 1, 21, NULL, N'甲戊庚牛羊')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianKui', NULL, N'天魁', 0, 2, 6, NULL, NULL, 1, NULL, NULL, NULL, 1, 21, NULL, N'乙己鼠猴乡')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianKui', NULL, N'天魁', 0, 3, 4, NULL, NULL, 12, NULL, NULL, NULL, 1, 21, NULL, N'丙丁猪鸡位')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianKui', NULL, N'天魁', 0, 9, 10, NULL, NULL, 4, NULL, NULL, NULL, 1, 21, NULL, N'壬癸兔蛇藏')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianKui', NULL, N'天魁', 0, 8, NULL, NULL, NULL, 7, NULL, NULL, NULL, 1, 21, NULL, N'六辛逢马虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天钺', 0, 1, 5, 7, NULL, 8, NULL, NULL, NULL, 1, 22, NULL, N'甲戊庚牛羊')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天钺', 0, 2, 6, NULL, NULL, 9, NULL, NULL, NULL, 1, 22, NULL, N'乙己鼠猴乡')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天钺', 0, 3, 4, NULL, NULL, 10, NULL, NULL, NULL, 1, 22, NULL, N'丙丁猪鸡位')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天钺', 0, 9, 10, NULL, NULL, 6, NULL, NULL, NULL, 1, 22, NULL, N'壬癸兔蛇藏')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天钺', 0, 8, NULL, NULL, NULL, 3, NULL, NULL, NULL, 1, 22, NULL, N'六辛逢马虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 1, NULL, NULL, NULL, 3, NULL, NULL, NULL, 1, 25, NULL, N'甲禄在寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 2, NULL, NULL, NULL, 4, NULL, NULL, NULL, 1, 25, NULL, N'乙禄在卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 3, 5, NULL, NULL, 6, NULL, NULL, NULL, 1, 25, NULL, N'丙戊禄在巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 4, 6, NULL, NULL, 7, NULL, NULL, NULL, 1, 25, NULL, N'丁己禄在午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 7, NULL, NULL, NULL, 9, NULL, NULL, NULL, 1, 25, NULL, N'庚禄在申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 8, NULL, NULL, NULL, 10, NULL, NULL, NULL, 1, 25, NULL, N'辛禄在酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 9, NULL, NULL, NULL, 12, NULL, NULL, NULL, 1, 25, NULL, N'壬禄在亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLuCun', NULL, N'禄存', 0, 10, NULL, NULL, NULL, 1, NULL, NULL, NULL, 1, 25, NULL, N'癸禄在子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuoXing', NULL, N'火星', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 3, 2, 15, NULL, N'申子辰人寅戌扬')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuoXing', NULL, N'火星', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 2, 2, 15, NULL, N'寅午戌人丑卯方')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuoXing', NULL, N'火星', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 4, 2, 15, NULL, N'巳酉丑人卯戌位')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuoXing', NULL, N'火星', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 10, 2, 15, NULL, N'亥卯未人酉戌房')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLingXing', NULL, N'铃星', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 11, 2, 16, NULL, N'申子辰人寅戌扬')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLingXing', NULL, N'铃星', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 4, 2, 16, NULL, N'寅午戌人丑卯方')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLingXing', NULL, N'铃星', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 11, 2, 16, NULL, N'巳酉丑人卯戌位')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLingXing', NULL, N'铃星', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 11, 2, 16, NULL, N'申子辰人寅戌扬')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 1, NULL, NULL, NULL, 8, NULL, NULL, NULL, 1, 62, NULL, N'甲喜羊鸡乙龙猴')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 2, NULL, NULL, NULL, 5, NULL, NULL, NULL, 1, 62, NULL, N'甲喜羊鸡乙龙猴')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 3, NULL, NULL, NULL, 6, NULL, NULL, NULL, 1, 62, NULL, N'丙年蛇鼠一窝谋')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 4, NULL, NULL, NULL, 3, NULL, NULL, NULL, 1, 62, NULL, N'丁虎擒猪戊玉兔')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 5, NULL, NULL, NULL, 4, NULL, NULL, NULL, 1, 62, NULL, N'丁虎擒猪戊玉兔')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 6, NULL, NULL, NULL, 10, NULL, NULL, NULL, 1, 62, NULL, N'己鸡居然与虎俦')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 7, NULL, NULL, NULL, 12, NULL, NULL, NULL, 1, 62, NULL, N'庚猪马辛鸡蛇走')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 8, NULL, NULL, NULL, 10, NULL, NULL, NULL, 1, 62, NULL, N'庚猪马辛鸡蛇走')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 9, NULL, NULL, NULL, 11, NULL, NULL, NULL, 1, 62, NULL, N'壬犬马癸马蛇游')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianGuan', NULL, N'天官', 0, 10, NULL, NULL, NULL, 7, NULL, NULL, NULL, 1, 62, NULL, N'壬犬马癸马蛇游')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu', NULL, N'天福', 0, 1, NULL, NULL, NULL, 10, NULL, NULL, NULL, 1, 63, NULL, N'甲喜羊鸡乙龙猴')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu', NULL, N'天福', 0, 2, NULL, NULL, NULL, 9, NULL, NULL, NULL, 1, 63, NULL, N'甲喜羊鸡乙龙猴')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu', NULL, N'天福', 0, 3, NULL, NULL, NULL, 1, NULL, NULL, NULL, 1, 63, NULL, N'丙年蛇鼠一窝谋')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu', NULL, N'天福', 0, 4, NULL, NULL, NULL, 12, NULL, NULL, NULL, 1, 63, NULL, N'丁虎擒猪戊玉兔')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu
', NULL, N'天福', 0, 5, NULL, NULL, NULL, 4, NULL, NULL, NULL, 1, 63, NULL, N'丁虎擒猪戊玉兔')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu
', NULL, N'天福', 0, 6, NULL, NULL, NULL, 3, NULL, NULL, NULL, 1, 63, NULL, N'己鸡居然与虎俦')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu
', NULL, N'天福', 0, 7, NULL, NULL, NULL, 7, NULL, NULL, NULL, 1, 63, NULL, N'庚猪马辛鸡蛇走')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu
', NULL, N'天福', 0, 8, NULL, NULL, NULL, 6, NULL, NULL, NULL, 1, 63, NULL, N'庚猪马辛鸡蛇走')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu
', NULL, N'天福', 0, 9, NULL, NULL, NULL, 7, NULL, NULL, NULL, 1, 63, NULL, N'壬犬马癸马蛇游')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianFu
', NULL, N'天福', 0, 10, NULL, NULL, NULL, 6, NULL, NULL, NULL, 1, 63, NULL, N'壬犬马癸马蛇游')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 1, 4, NULL, NULL, 6, NULL, NULL, NULL, 1, 49, NULL, N'甲丁食蛇口')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 2, 5, 8, NULL, 7, NULL, NULL, NULL, 1, 49, NULL, N'乙戊辛马方')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 3, NULL, NULL, NULL, 1, NULL, NULL, NULL, 1, 49, NULL, N'丙从鼠口得')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 6, NULL, NULL, NULL, 9, NULL, NULL, NULL, 1, 49, NULL, N'己食于猴房')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 7, NULL, NULL, NULL, 3, NULL, NULL, NULL, 1, 49, NULL, N'庚食虎头上')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 9, NULL, NULL, NULL, 10, NULL, NULL, NULL, 1, 49, NULL, N'壬鸡癸猪堂')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianChu', NULL, N'天厨', 0, 10, NULL, NULL, NULL, 12, NULL, NULL, NULL, 1, 49, NULL, N'壬鸡癸猪堂')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieKong', NULL, N'截空', 0, 1, 6, NULL, NULL, 9, 10, NULL, NULL, NULL, NULL, NULL, N'甲己年申酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieKong', NULL, N'截空', 0, 2, 7, NULL, NULL, 7, 8, NULL, NULL, NULL, NULL, NULL, N'乙庚年午未')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieKong', NULL, N'截空', 0, 3, 8, NULL, NULL, 5, 6, NULL, NULL, NULL, NULL, NULL, N'丙辛年辰巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieKong', NULL, N'截空', 0, 4, 9, NULL, NULL, 3, 4, NULL, NULL, NULL, NULL, NULL, N'丁壬年寅卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieKong', NULL, N'截空', 0, 5, 10, NULL, NULL, 1, 2, NULL, NULL, NULL, NULL, NULL, N'戊癸年子丑')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianMa', NULL, N'天马', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 3, 2, 26, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianMa', NULL, N'天马', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 9, 2, 26, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianMa', NULL, N'天马', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 12, 2, 26, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianMa', NULL, N'天马', 0, NULL, NULL, NULL, NULL, 12, 4, 7, 6, 2, 26, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuCheng', NULL, N'孤辰', 0, NULL, NULL, NULL, NULL, 3, 4, 5, 6, 2, 35, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuCheng', NULL, N'孤辰', 0, NULL, NULL, NULL, NULL, 6, 7, 8, 9, 2, 35, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuCheng', NULL, N'孤辰', 0, NULL, NULL, NULL, NULL, 9, 10, 11, 12, 2, 35, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuCheng', NULL, N'孤辰', 0, NULL, NULL, NULL, NULL, 12, 1, 2, 3, 2, 35, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuaSu', NULL, N'寡宿', 0, NULL, NULL, NULL, NULL, 3, 4, 5, 2, 2, 36, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuaSu', NULL, N'寡宿', 0, NULL, NULL, NULL, NULL, 6, 7, 8, 5, 2, 36, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuaSu', NULL, N'寡宿', 0, NULL, NULL, NULL, NULL, 9, 10, 11, 8, 2, 36, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwGuaSu', NULL, N'寡宿', 0, NULL, NULL, NULL, NULL, 12, 1, 2, 11, 2, 36, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuaGai', NULL, N'华盖', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 5, 2, 39, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuaGai', NULL, N'华盖', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 11, 2, 39, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuaGai', NULL, N'华盖', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 2, 2, 39, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHuaGai', NULL, N'华盖', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 7, 2, 39, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwXianChi', NULL, N'咸池', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 10, 2, 43, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwXianChi', NULL, N'咸池', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 4, 2, 43, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwXianChi', NULL, N'咸池', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 7, 2, 43, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwXianChi', NULL, N'咸池', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 1, 2, 43, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, 9, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 2, NULL, NULL, 10, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 3, NULL, NULL, 11, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 4, NULL, NULL, 6, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 5, NULL, NULL, 7, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 6, NULL, NULL, 8, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 7, NULL, NULL, 3, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 8, NULL, NULL, 4, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 9, NULL, NULL, 5, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, 12, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 11, NULL, NULL, 1, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFeiLian', NULL, N'蜚廉', 0, NULL, NULL, NULL, NULL, 12, NULL, NULL, 2, 2, 45, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwPoSui', NULL, N'破碎', 0, NULL, NULL, NULL, NULL, 1, 4, NULL, 6, 2, 42, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwPoSui', NULL, N'破碎', 0, NULL, NULL, NULL, NULL, 7, 10, NULL, 6, 2, 42, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwPoSui', NULL, N'破碎', 0, NULL, NULL, NULL, NULL, 3, 6, NULL, 10, 2, 42, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwPoSui', NULL, N'破碎', 0, NULL, NULL, NULL, NULL, 9, 12, NULL, 10, 2, 42, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwPoSui', NULL, N'破碎', 0, NULL, NULL, NULL, NULL, 2, 5, NULL, 2, 2, 42, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwPoSui', NULL, N'破碎', 0, NULL, NULL, NULL, NULL, 8, 11, NULL, 2, 2, 42, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianKu', NULL, N'天哭', 0, NULL, NULL, NULL, NULL, 7, NULL, NULL, NULL, 3, 31, 0, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianXu', NULL, N'天虚', 0, NULL, NULL, NULL, NULL, 7, NULL, NULL, NULL, 3, 32, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwHongLuan', NULL, N'红鸾', 0, NULL, NULL, NULL, NULL, 4, NULL, NULL, NULL, 3, 33, 0, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianXi', NULL, N'天喜', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, NULL, 3, 34, 0, NULL)
GO
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLongDe', NULL, N'龙德', 0, NULL, NULL, NULL, NULL, 8, NULL, NULL, NULL, 3, 64, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYueDe', NULL, N'月德', 0, NULL, NULL, NULL, NULL, 6, NULL, NULL, NULL, 3, 38, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianDe', NULL, N'天德', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, NULL, 3, 37, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwNianDe', NULL, N'年德', 0, NULL, NULL, NULL, NULL, 11, NULL, NULL, NULL, 3, 65, 0, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwLongChi', NULL, N'龙池', 0, NULL, NULL, NULL, NULL, 5, NULL, NULL, NULL, 3, 29, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwFengGe', NULL, N'凤阁', 0, NULL, NULL, NULL, NULL, 11, NULL, NULL, NULL, 3, 30, 0, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianXing', NULL, N'天刑', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, NULL, 4, 51, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYao', NULL, N'天姚', 0, NULL, NULL, NULL, NULL, 2, NULL, NULL, NULL, 4, 52, 1, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieSheng', NULL, N'解神', 0, NULL, NULL, NULL, NULL, 1, 2, NULL, 9, 5, 54, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieSheng', NULL, N'解神', 0, NULL, NULL, NULL, NULL, 3, 4, NULL, 11, 5, 54, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieSheng', NULL, N'解神', 0, NULL, NULL, NULL, NULL, 5, 6, NULL, 1, 5, 54, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieSheng', NULL, N'解神', 0, NULL, NULL, NULL, NULL, 7, 8, NULL, 3, 5, 54, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieSheng', NULL, N'解神', 0, NULL, NULL, NULL, NULL, 9, 10, NULL, 5, 5, 54, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJieSheng', NULL, N'解神', 0, NULL, NULL, NULL, NULL, 11, 12, NULL, 7, 5, 54, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianWu', NULL, N'天巫', 0, NULL, NULL, NULL, NULL, 1, 5, 9, 6, 5, 53, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianWu', NULL, N'天巫', 0, NULL, NULL, NULL, NULL, 2, 6, 10, 9, 5, 53, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianWu', NULL, N'天巫', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 3, 5, 53, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianWu', NULL, N'天巫', 0, NULL, NULL, NULL, NULL, 4, 8, 12, 12, 5, 53, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 1, 11, NULL, 11, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 2, NULL, NULL, 6, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 3, NULL, NULL, 5, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 4, 9, 12, 3, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 5, 8, NULL, 8, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 6, NULL, NULL, 4, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 7, NULL, NULL, 12, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwTianYue', NULL, N'天月', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, 7, 5, 50, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYingSha', NULL, N'阴煞', 0, NULL, NULL, NULL, NULL, 1, 7, NULL, 3, 5, 55, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYingSha', NULL, N'阴煞', 0, NULL, NULL, NULL, NULL, 2, 8, NULL, 1, 5, 55, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYingSha', NULL, N'阴煞', 0, NULL, NULL, NULL, NULL, 3, 9, NULL, 11, 5, 55, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYingSha', NULL, N'阴煞', 0, NULL, NULL, NULL, NULL, 4, 10, NULL, 9, 5, 55, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYingSha', NULL, N'阴煞', 0, NULL, NULL, NULL, NULL, 5, 11, NULL, 7, 5, 55, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwYingSha', NULL, N'阴煞', 0, NULL, NULL, NULL, NULL, 6, 12, NULL, 5, 5, 55, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJiangQian', NULL, N'将前', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 1, NULL, NULL, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJiangQian', NULL, N'将前', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 7, NULL, NULL, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJiangQian', NULL, N'将前', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 10, NULL, NULL, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'zwJiangQian', NULL, N'将前', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 4, NULL, NULL, NULL, NULL)
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha1', 1, N'天乙贵人', 0, 1, 5, NULL, NULL, 2, 8, NULL, NULL, 6, NULL, NULL, N'甲戊兼牛羊')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha1', 1, N'天乙贵人', 0, 2, 6, NULL, NULL, 1, 9, NULL, NULL, 6, NULL, NULL, N'乙己鼠猴乡')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha1', 1, N'天乙贵人', 0, 3, 4, NULL, NULL, 10, 12, NULL, NULL, 6, NULL, NULL, N'丙丁猪鸡位')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha1', 1, N'天乙贵人', 0, 9, 10, NULL, NULL, 4, 6, NULL, NULL, 6, NULL, NULL, N'壬癸兔蛇藏')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha1', 1, N'天乙贵人', 0, 7, 8, NULL, NULL, 3, 7, NULL, NULL, 6, NULL, NULL, N'庚辛逢虎马')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha2', 2, N'太极贵人', 0, 1, 2, NULL, NULL, 1, 7, NULL, NULL, 6, NULL, NULL, N'甲乙生人子午中')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha2', 2, N'太极贵人', 0, 3, 4, NULL, NULL, 4, 10, NULL, NULL, 6, NULL, NULL, N'丙丁鸡兔定亨通')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha2', 2, N'太极贵人', 0, 5, 6, NULL, NULL, 5, 11, 2, 8, 6, NULL, NULL, N'戊己两干临四季')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha2', 2, N'太极贵人', 0, 7, 8, NULL, NULL, 3, 12, NULL, NULL, 6, NULL, NULL, N'庚辛寅亥禄丰隆')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha2', 2, N'太极贵人', 0, 9, 10, NULL, NULL, 6, 9, NULL, NULL, 6, NULL, NULL, N'壬癸巳申偏喜美')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 4, NULL, NULL, NULL, 3, NULL, NULL, NULL, 8, NULL, NULL, N'正月生者见丁')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, NULL, NULL, NULL, NULL, 4, NULL, NULL, 9, 8, NULL, NULL, N'二月生者见申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 9, NULL, NULL, NULL, 5, NULL, NULL, NULL, 8, NULL, NULL, N'三月生者见壬')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 8, NULL, NULL, NULL, 6, NULL, NULL, NULL, 8, NULL, NULL, N'四月生者见辛')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, NULL, NULL, NULL, NULL, 7, NULL, NULL, 12, 8, NULL, NULL, N'五月生者见亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 1, NULL, NULL, NULL, 8, NULL, NULL, NULL, 8, NULL, NULL, N'六月生者见甲')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 10, NULL, NULL, NULL, 9, NULL, NULL, NULL, 8, NULL, NULL, N'七月生者见癸')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, 3, 8, NULL, NULL, N'八月生者见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 3, NULL, NULL, NULL, 11, NULL, NULL, NULL, 8, NULL, NULL, N'九月生者见丙')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 2, NULL, NULL, NULL, 12, NULL, NULL, NULL, 8, NULL, NULL, N'十月生者见乙')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, 6, 8, NULL, NULL, N'十一月生者见巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha3', 3, N'天德贵人', 0, 7, NULL, NULL, NULL, 2, NULL, NULL, NULL, 8, NULL, NULL, N'十二月生者见庚')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha4', 4, N'月德贵人', 0, 3, NULL, NULL, NULL, 3, 7, 11, NULL, 8, NULL, NULL, N'寅午戌月在丙')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha4', 4, N'月德贵人', 0, 9, NULL, NULL, NULL, 9, 1, 5, NULL, 8, NULL, NULL, N'申子辰月在壬')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha4', 4, N'月德贵人', 0, 1, NULL, NULL, NULL, 12, 4, 8, NULL, 8, NULL, NULL, N'亥卯未月在甲')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha4', 4, N'月德贵人', 0, 7, NULL, NULL, NULL, 6, 10, 2, NULL, 8, NULL, NULL, N'巳酉丑月在庚')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha7', 7, N'三奇贵人', 0, 1, 5, 7, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, N'天上三奇甲戊庚')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha7', 7, N'三奇贵人', 0, 2, 3, 4, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, N'地下三奇乙丙丁')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha7', 7, N'三奇贵人', 0, 9, 10, 8, NULL, NULL, NULL, NULL, NULL, 7, NULL, NULL, N'人中三奇壬癸辛')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 1, NULL, NULL, NULL, 11, NULL, NULL, NULL, 6, NULL, NULL, N'甲见戌')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 2, NULL, NULL, NULL, 12, NULL, NULL, NULL, 6, NULL, NULL, N'乙见亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 3, NULL, NULL, NULL, 2, NULL, NULL, NULL, 6, NULL, NULL, N'丙见丑')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 4, NULL, NULL, NULL, 3, NULL, NULL, NULL, 6, NULL, NULL, N'丁见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 5, NULL, NULL, NULL, 2, NULL, NULL, NULL, 6, NULL, NULL, N'戊见丑')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 6, NULL, NULL, NULL, 3, NULL, NULL, NULL, 6, NULL, NULL, N'己见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 7, NULL, NULL, NULL, 5, NULL, NULL, NULL, 6, NULL, NULL, N'庚见辰')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 8, NULL, NULL, NULL, 6, NULL, NULL, NULL, 6, NULL, NULL, N'辛见巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 9, NULL, NULL, NULL, 8, NULL, NULL, NULL, 6, NULL, NULL, N'壬见未')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha8', 8, N'国印贵人', 0, 10, NULL, NULL, NULL, 9, NULL, NULL, NULL, 6, NULL, NULL, N'癸见申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha11', 11, N'德秀贵人', 0, 3, 4, 5, 10, 3, 7, 11, NULL, 20, NULL, NULL, N'寅午戌月, 丙丁为德, 戊癸为秀.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha11', 11, N'德秀贵人', 0, 9, 10, 3, 8, 9, 1, 5, NULL, 20, NULL, NULL, N'申子辰月, 壬癸戊己为德, 丙辛甲己为秀.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha11', 11, N'德秀贵人', 0, 5, 6, 1, 6, 9, 1, 5, NULL, 20, NULL, NULL, N'申子辰月, 壬癸戊己为德, 丙辛甲己为秀.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha11', 11, N'德秀贵人', 0, 7, 8, 2, 7, 6, 10, 2, NULL, 20, NULL, NULL, N'巳酉丑月, 庚辛为德, 乙庚为秀.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha11', 11, N'德秀贵人', 0, 1, 2, 4, 9, 12, 4, 8, NULL, 20, NULL, NULL, N'亥卯未月, 甲乙为德, 丁壬为秀.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha12', 12, N'驿马星', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 3, 11, NULL, NULL, N'申子辰马在寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha12', 12, N'驿马星', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 9, 11, NULL, NULL, N'寅午戌马在申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha12', 12, N'驿马星', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 12, 11, NULL, NULL, N'巳酉丑马在亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha12', 12, N'驿马星', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 6, 11, NULL, NULL, N'亥卯未马在已')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha13', 13, N'华盖星', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 11, 11, NULL, NULL, N'寅午戌见戌')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha13', 13, N'华盖星', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 8, 11, NULL, NULL, N'亥卯未见未')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha13', 13, N'华盖星', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 5, 11, NULL, NULL, N'申子辰见辰')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha13', 13, N'华盖星', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 2, 11, NULL, NULL, N'巳酉丑见丑')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha14', 14, N'将星', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 7, 11, NULL, NULL, N'寅午戌见午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha14', 14, N'将星', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 10, 11, NULL, NULL, N'巳酉丑见酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha14', 14, N'将星', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 1, 11, NULL, NULL, N'申子辰见子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha14', 14, N'将星', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 4, 11, NULL, NULL, N'亥卯未见卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 1, NULL, NULL, NULL, 5, NULL, NULL, NULL, 6, NULL, NULL, N'甲龙乙蛇丙戊羊')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 2, NULL, NULL, NULL, 6, NULL, NULL, NULL, 6, NULL, NULL, N'甲龙乙蛇丙戊羊')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 3, 5, NULL, NULL, 8, NULL, NULL, NULL, 6, NULL, NULL, N'甲龙乙蛇丙戊羊')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 4, 6, NULL, NULL, 9, NULL, NULL, NULL, 6, NULL, NULL, N'丁己猴歌庚犬方')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 7, NULL, NULL, NULL, 11, NULL, NULL, NULL, 6, NULL, NULL, N'丁己猴歌庚犬方')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 8, NULL, NULL, NULL, 12, NULL, NULL, NULL, 6, NULL, NULL, N'辛猪壬牛癸逢虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 9, NULL, NULL, NULL, 2, NULL, NULL, NULL, 6, NULL, NULL, N'辛猪壬牛癸逢虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha15', 15, N'金舆星', 0, 10, NULL, NULL, NULL, 3, NULL, NULL, NULL, 6, NULL, NULL, N'辛猪壬牛癸逢虎')
GO
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha16', 16, N'金神', 0, 2, 6, 10, NULL, 2, 6, 10, NULL, 16, NULL, NULL, N'金神者, 乙丑, 己巳, 癸酉三组干支.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 3, NULL, NULL, 2, 8, NULL, NULL, N'寅月见丑')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 4, NULL, NULL, 3, 8, NULL, NULL, N'卯月见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 5, NULL, NULL, 4, 8, NULL, NULL, N'辰月见卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 6, NULL, NULL, 5, 8, NULL, NULL, N'巳月见辰')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 7, NULL, NULL, 6, 8, NULL, NULL, N'午月见已')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 8, NULL, NULL, 7, 8, NULL, NULL, N'未月见午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 9, NULL, NULL, 8, 8, NULL, NULL, N'申月见未')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 10, NULL, NULL, 9, 8, NULL, NULL, N'酉月见申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 11, NULL, NULL, 10, 8, NULL, NULL, N'戌月见酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 12, NULL, NULL, 11, 8, NULL, NULL, N'亥月见戌')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 1, NULL, NULL, 12, 8, NULL, NULL, N'子月见亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha17', 17, N'天医', 0, NULL, NULL, NULL, NULL, 2, NULL, NULL, 1, 8, NULL, NULL, N'丑月见子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha19', 19, N'拱禄', 0, 10, 10, 10, 10, 12, 2, 2, 12, 21, NULL, NULL, N'癸亥日癸丑时, 癸丑日癸亥时, 拱子禄.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha19', 19, N'拱禄', 0, 4, 4, 6, 6, 6, 8, 8, 6, 21, NULL, NULL, N'丁巳日丁未时, 己未日己巳时, 拱午禄.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha19', 19, N'拱禄', 0, 5, 5, NULL, NULL, 5, 7, NULL, NULL, 21, NULL, NULL, N'戊辰日戊午时, 拱巳禄.')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha20', 20, N'天赦', 0, NULL, NULL, NULL, 5, 3, 4, 5, 3, 14, NULL, NULL, N'寅卯辰月生戊寅日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha20', 20, N'天赦', 0, NULL, NULL, NULL, 1, 6, 7, 8, 7, 14, NULL, NULL, N'巳午未月生甲午日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha20', 20, N'天赦', 0, NULL, NULL, NULL, 5, 9, 10, 11, 9, 14, NULL, NULL, N'申酉戌月生戊申日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha20', 20, N'天赦', 0, NULL, NULL, NULL, 1, 12, 1, 2, 1, 14, NULL, NULL, N' 亥子丑月生甲子日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 3, 9, NULL, 1, 8, NULL, NULL, N'寅、申月见子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 4, 8, NULL, 12, 8, NULL, NULL, N'卯、末月见亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 5, 7, NULL, 11, 8, NULL, NULL, N'辰、午月见戌')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 6, NULL, NULL, 10, 8, NULL, NULL, N'巳月见酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 10, 2, NULL, 2, 8, NULL, NULL, N'酉、丑月见丑')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 11, 1, NULL, 3, 8, NULL, NULL, N'戌、子月见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha21', 21, N'阴注阳受', 0, NULL, NULL, NULL, NULL, 12, NULL, NULL, 4, 8, NULL, NULL, N'亥月见卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha22', 22, N'魁罡', 0, 9, 7, 7, 5, 5, 11, 5, 11, 15, NULL, NULL, N'壬辰庚戌与庚辰,戊戌魁罡四座神')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha24', 24, N'灾煞', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 7, 11, NULL, NULL, N'申子辰见午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha24', 24, N'灾煞', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 10, 11, NULL, NULL, N'亥卯未见酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha24', 24, N'灾煞', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 1, 11, NULL, NULL, N'寅午戌见子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha24', 24, N'灾煞', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 4, 11, NULL, NULL, N'巳酉丑见卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha25', 25, N'劫煞', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 6, 11, NULL, NULL, N'申子辰见巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha25', 25, N'劫煞', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 9, 11, NULL, NULL, N'亥卯未见申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha25', 25, N'劫煞', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 12, 11, NULL, NULL, N'寅午戌见亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha25', 25, N'劫煞', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 3, 11, NULL, NULL, N'巳酉丑见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha26', 26, N'天罗地网', 0, NULL, NULL, NULL, NULL, 5, NULL, NULL, 6, 11, NULL, NULL, N'辰年日支见巳支')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha26', 26, N'天罗地网', 0, NULL, NULL, NULL, NULL, 6, NULL, NULL, 5, 11, NULL, NULL, N'巳年日支见辰支')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha26', 26, N'天罗地网', 0, NULL, NULL, NULL, NULL, 11, NULL, NULL, 12, 11, NULL, NULL, N'戌年日支见亥支')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha26', 26, N'天罗地网', 0, NULL, NULL, NULL, NULL, 12, NULL, NULL, 11, 11, NULL, NULL, N'亥年日支见戌支')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha28', 28, N'亡神', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 12, 11, NULL, NULL, N'申子辰见亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha28', 28, N'亡神', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 6, 11, NULL, NULL, N'寅午戌见巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha28', 28, N'亡神', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 9, 11, NULL, NULL, N'巳酉丑见申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha28', 28, N'亡神', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 3, 11, NULL, NULL, N'亥卯未见寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha30', 30, N'咸池(桃花)', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 10, 11, NULL, NULL, N'申子辰在酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha30', 30, N'咸池(桃花)', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 4, 11, NULL, NULL, N'寅午戌在卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha30', 30, N'咸池(桃花)', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 7, 11, NULL, NULL, N'巳酉丑在午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha30', 30, N'咸池(桃花)', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 1, 11, NULL, NULL, N'亥卯未在子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha31', 31, N'孤辰', 0, NULL, NULL, NULL, NULL, 12, 1, 2, 3, 12, NULL, NULL, N'亥子丑人，见寅为孤，见戌为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha31', 31, N'孤辰', 0, NULL, NULL, NULL, NULL, 3, 4, 5, 6, 12, NULL, NULL, N'寅卯辰人，见巳为孤，见丑为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha31', 31, N'孤辰', 0, NULL, NULL, NULL, NULL, 6, 7, 8, 9, 12, NULL, NULL, N'巳午未人，见申为孤，见辰为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha31', 31, N'孤辰', 0, NULL, NULL, NULL, NULL, 9, 10, 11, 12, 12, NULL, NULL, N'申酉戌人，见亥为孤，见未为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha32', 32, N'六厄', 0, NULL, NULL, NULL, NULL, 9, 1, 5, 4, 12, NULL, NULL, N'申子辰见卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha32', 32, N'六厄', 0, NULL, NULL, NULL, NULL, 3, 7, 11, 10, 12, NULL, NULL, N'寅午戌见酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha32', 32, N'六厄', 0, NULL, NULL, NULL, NULL, 6, 10, 2, 1, 12, NULL, NULL, N'巳酉丑见子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha32', 32, N'六厄', 0, NULL, NULL, NULL, NULL, 12, 4, 8, 7, 12, NULL, NULL, N'亥卯未见午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha33', 33, N'阴差阳错', 0, 3, 3, 4, 4, 7, 1, 8, 2, 15, NULL, NULL, N'丙午日 丙子日 丁未日丁丑日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha33', 33, N'阴差阳错', 0, 5, 5, 8, 8, 9, 3, 10, 4, 15, NULL, NULL, N'戊申日 戊寅日 辛酉日 辛卯日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha33', 33, N'阴差阳错', 0, 9, 9, 10, 10, 11, 5, 6, 12, 15, NULL, NULL, N'壬戌日壬辰日 癸巳日 癸亥日')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha34', 34, N'十恶大败', 0, 1, 2, 9, NULL, 5, 6, 9, NULL, 15, NULL, NULL, N'甲辰乙巳与壬申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha34', 34, N'十恶大败', 0, 3, 4, 7, NULL, 9, 12, 5, NULL, 15, NULL, NULL, N'丙申丁亥及庚辰')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha34', 34, N'十恶大败', 0, 5, 10, 8, NULL, 11, 12, 6, NULL, 15, NULL, NULL, N'戊戌癸亥加辛巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha34', 34, N'十恶大败', 0, 6, NULL, NULL, NULL, 2, NULL, NULL, NULL, 15, NULL, NULL, N'己丑都来十位神')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 7, 3, 4, 5, 9, 14, NULL, NULL, N'春庚申辛酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 8, 3, 4, 5, 10, 14, NULL, NULL, N'春庚申辛酉')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 9, 6, 7, 8, 1, 14, NULL, NULL, N'夏壬子癸亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 10, 6, 7, 8, 12, 14, NULL, NULL, N'夏壬子癸亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 1, 9, 10, 11, 3, 14, NULL, NULL, N'秋甲寅乙卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 2, 9, 10, 11, 4, 14, NULL, NULL, N'秋甲寅乙卯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 3, 12, 1, 2, 7, 14, NULL, NULL, N'冬丙午丁巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha36', 36, N'四废日', 0, NULL, NULL, NULL, 4, 12, 1, 2, 6, 14, NULL, NULL, N'冬丙午丁巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 2, NULL, NULL, NULL, 6, NULL, NULL, NULL, 21, NULL, NULL, N'乙巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 4, NULL, NULL, NULL, 6, NULL, NULL, NULL, 21, NULL, NULL, N'丁巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 8, NULL, NULL, NULL, 12, NULL, NULL, NULL, 21, NULL, NULL, N'辛亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 5, NULL, NULL, NULL, 9, NULL, NULL, NULL, 21, NULL, NULL, N'戊申')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 1, NULL, NULL, NULL, 3, NULL, NULL, NULL, 21, NULL, NULL, N'甲寅')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 5, NULL, NULL, NULL, 7, NULL, NULL, NULL, 21, NULL, NULL, N'戊午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 9, NULL, NULL, NULL, 1, NULL, NULL, NULL, 21, NULL, NULL, N'壬子')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha38', 38, N'孤鸾煞', 0, 3, NULL, NULL, NULL, 7, NULL, NULL, NULL, 21, NULL, NULL, N'丙午')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 1, NULL, NULL, NULL, 6, NULL, NULL, NULL, 6, NULL, NULL, N'甲乙蛇马报君知')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 2, NULL, NULL, NULL, 7, NULL, NULL, NULL, 6, NULL, NULL, N'甲乙蛇马报君知')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 3, 5, NULL, NULL, 9, NULL, NULL, NULL, 6, NULL, NULL, N'丙戊申宫丁已鸡')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 4, 6, NULL, NULL, 10, NULL, NULL, NULL, 6, NULL, NULL, N'丙戊申宫丁已鸡')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 7, NULL, NULL, NULL, 12, NULL, NULL, NULL, 6, NULL, NULL, N'庚猪辛鼠壬逢虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 8, NULL, NULL, NULL, 1, NULL, NULL, NULL, 6, NULL, NULL, N'庚猪辛鼠壬逢虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 9, NULL, NULL, NULL, 3, NULL, NULL, NULL, 6, NULL, NULL, N'庚猪辛鼠壬逢虎')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha39', 39, N'文昌贵人', 0, 10, NULL, NULL, NULL, 4, NULL, NULL, NULL, 6, NULL, NULL, N'癸人见兔入云梯')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha40', 40, N'寡宿', 0, NULL, NULL, NULL, NULL, 12, 1, 2, 11, 12, NULL, NULL, N'亥子丑人，见寅为孤，见戌为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha40', 40, N'寡宿', 0, NULL, NULL, NULL, NULL, 3, 4, 5, 2, 12, NULL, NULL, N'寅卯辰人，见巳为孤，见丑为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha40', 40, N'寡宿', 0, NULL, NULL, NULL, NULL, 6, 7, 8, 5, 12, NULL, NULL, N'巳午未人，见申为孤，见辰为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha40', 40, N'寡宿', 0, NULL, NULL, NULL, NULL, 9, 10, 11, 8, 12, NULL, NULL, N'申酉戌人，见亥为孤，见未为寡。')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 1, 3, NULL, NULL, 3, 1, NULL, NULL, 6, NULL, NULL, N'甲丙相邀入虎乡，更逢鼠穴最高强')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 5, NULL, NULL, NULL, 9, NULL, NULL, NULL, 6, NULL, NULL, N'戊猴己未丁宜亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 6, NULL, NULL, NULL, 8, NULL, NULL, NULL, 6, NULL, NULL, N'戊猴己未丁宜亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 4, NULL, NULL, NULL, 12, NULL, NULL, NULL, 6, NULL, NULL, N'戊猴己未丁宜亥')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 2, 10, NULL, NULL, 2, 4, NULL, NULL, 6, NULL, NULL, N'乙癸逢牛卯禄昌')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 7, NULL, NULL, NULL, 7, NULL, NULL, NULL, 6, NULL, NULL, N'庚赶马头辛到巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 8, NULL, NULL, NULL, 6, NULL, NULL, NULL, 6, NULL, NULL, N'庚赶马头辛到巳')
INSERT [dbo].[zSetting] ([SKey], [SKeyId], [SValue], [Disabled], [GanId1], [GanId2], [GanId3], [GanId4], [ZhiId1], [ZhiId2], [ZhiId3], [ZhiId4], [TypeId], [XingYaoId], [ShunNi], [SNote]) VALUES (N'bzShengSha42', 42, N'福星贵人', 0, 9, NULL, NULL, NULL, 5, NULL, NULL, NULL, 6, NULL, NULL, N'壬骑龙背喜非常')
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 1, N'东', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 2, N'南', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 3, N'西', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 4, N'北', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 5, N'中央', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 6, N'东南', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 7, N'西南', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 8, N'东北', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzFangWei', 9, N'西北', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhi', 1, N'干', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhi', 2, N'支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzQiangRuo', 1, N'强', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzQiangRuo', 2, N'弱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengKe', 1, N'生', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengKe', 2, N'克', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 1, N'正印', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 2, N'偏印', N'枭', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 3, N'伤官', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 4, N'食神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 5, N'正官', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 6, N'七杀', N'偏官', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 7, N'正财', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 8, N'偏财', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 9, N'劫财', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShiSheng', 10, N'比肩', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 1, N'长生', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 2, N'沐浴', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 3, N'冠带', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 6, N'临官', N'禄', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 7, N'帝旺', N'羊刃', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 8, N'衰', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 9, N'病', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 10, N'死', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 11, N'墓', N'库', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 12, N'绝', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 13, N'胎', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzWangShuai', 14, N'养', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 1, N'邢冲合害', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 2, N'婚姻', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 3, N'财运', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 4, N'疾病伤残', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 5, N'六亲', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 6, N'子女', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 7, N'事业', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 8, N'学业', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 9, N'官讼刑狱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 10, N'性格', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXinXi', 99, N'其它', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzYingYang', 1, N'阳', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzYingYang', 2, N'阴', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 1, N'海中金', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 2, N'炉中火', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 3, N'大林木', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 4, N'路旁土', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 5, N'剑锋金', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 6, N'山头火', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 7, N'涧下水', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 8, N'城头土', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 9, N'白蜡金', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 10, N'杨柳木', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 11, N'泉中水', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 12, N'屋上土', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 13, N'霹雳火', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 14, N'松柏木', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 15, N'长流水', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 16, N'沙中金', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 17, N'山下火', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 18, N'平地木', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 19, N'壁上土', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 20, N'金箔金', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 21, N'佛灯火', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 22, N'天河水', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 23, N'大驿土', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 24, N'钗钏金', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 25, N'桑拓木', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 26, N'沙中土', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 27, N'天上火', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 28, N'石榴木', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 29, N'大海水', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzNaYin', 30, N'大溪水', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 1, N'鼠', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 2, N'牛', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 3, N'虎', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 4, N'兔', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 5, N'龙', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 6, N'蛇', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 7, N'马', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 8, N'羊', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 9, N'猴', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 10, N'鸡', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 11, N'狗', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengXiao', 12, N'猪', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 1, N'年', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 2, N'月', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 3, N'日', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 4, N'时', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 5, N'大运', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 6, N'小运', NULL, 1)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 7, N'流年', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 8, N'命宫', NULL, 1)
GO
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiType', 9, N'胎元', NULL, 1)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzJiJie', 1, N'春', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzJiJie', 2, N'夏', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzJiJie', 3, N'秋', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzJiJie', 4, N'冬', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzJiJie', 5, N'长夏', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzJiJie', 6, N'四季', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 1, N'头', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 2, N'肩', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 3, N'额', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 4, N'舌齿', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 5, N'鼻面', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 6, N'筋', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 7, N'胸', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 8, N'胫', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzTiBiao', 9, N'足', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 1, N'胆', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 2, N'肝', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 3, N'小肠', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 4, N'心', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 5, N'胃', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 6, N'脾', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 7, N'大肠', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 8, N'肺', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 9, N'膀胱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzZangFu', 10, N'肾', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 1, N'正曜', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 2, N'煞曜', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 3, N'辅佐曜', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 4, N'杂曜', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 5, N'长生十二神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 6, N'太岁十二神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 7, N'将前诸星', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 8, N'博士十二神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwXingYaoType', 9, N'流曜', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXingBie', 1, N'男', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzXingBie', 2, N'女', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwPaiPanType', 1, N'命盘', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwPaiPanType', 2, N'大限盘', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwPaiPanType', 3, N'流年盘', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwPaiPanType', 4, N'小限盘', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 1, N'庙', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 2, N'旺', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 3, N'得地', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 4, N'利益', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 5, N'平和', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 6, N'不得地', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwMiaoXian', 7, N'落陷', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 1, N'相合', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 2, N'相冲', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 3, N'三合', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 4, N'三会', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 5, N'相害', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 6, N'相刑', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 7, N'半合', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGX', 8, N'拱合', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 6, N'年日干查四柱地支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 7, N'三干顺布紧连', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 8, N'以月支查四柱干支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 9, N'以月支查四柱干支相合者', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 10, N'年柱纳音查月日时柱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 11, N'年日支查四柱地支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 12, N'年支查四柱地支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 13, N'日干查四柱地支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 14, N'月支查日柱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 15, N'日柱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 16, N'时柱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 17, N'与年支相冲的前一位地支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 18, N'年支查前后n位', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 19, N'日旬查年月时支', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 20, N'月支查天干', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengShaCF', 21, N'日时柱', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGXType', 1, N'干合冲', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGXType', 2, N'支邢冲合害', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGXType', 3, N'十神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzGanZhiGXType', 4, N'旺衰', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 1, N'天乙贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 2, N'太极贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 3, N'天德贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 4, N'月德贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 5, N'天德合', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 6, N'月德合', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 7, N'三奇贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 8, N'国印贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 9, N'学堂', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 10, N'词馆', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 11, N'德秀贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 12, N'驿马星', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 13, N'华盖星', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 14, N'将星', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 15, N'金舆星', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 16, N'金神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 17, N'天医', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 18, N'禄神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 19, N'拱禄', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 20, N'天赦', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 21, N'阴注阳受', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 22, N'魁罡', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 23, N'羊刃', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 24, N'灾煞', NULL, 0)
GO
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 25, N'劫煞', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 26, N'天罗地网', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 27, N'勾绞煞', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 28, N'亡神', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 29, N'元辰', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 30, N'咸池(桃花)', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 31, N'孤辰', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 32, N'六厄', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 33, N'阴差阳错', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 34, N'十恶大败', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 35, N'六甲空亡', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 36, N'四废日', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 37, N'丧门吊客', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 38, N'孤鸾煞', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 39, N'文昌贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 40, N'寡宿', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 41, N'披麻', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'bzShengSha', 42, N'福星贵人', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 1, N'命宫', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 2, N'父母', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 3, N'福德', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 4, N'田宅', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 5, N'官禄', N'事业', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 6, N'交友', N'奴仆', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 7, N'迁移', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 8, N'疾厄', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 9, N'财帛', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 10, N'子女', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 11, N'夫妻', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 12, N'兄弟', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWei', 13, N'身', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 1, N'命宫', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 2, N'兄弟', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 3, N'夫妻', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 4, N'子女', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 5, N'财帛', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 6, N'疾厄', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 7, N'迁移', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 8, N'交友', N'奴仆', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 9, N'官禄', N'事业', 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 10, N'田宅', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 11, N'福德', NULL, 0)
INSERT [dbo].[zSuanMing] ([SKey], [SKeyId], [SValue], [SAlias], [SDisabled]) VALUES (N'zwGongWeiNi', 12, N'父母', NULL, 0)
SET IDENTITY_INSERT [dbo].[zWuHang] ON 

INSERT [dbo].[zWuHang] ([WuHangId], [WuHang], [WuHangJu], [JuShu], [QiZhiId]) VALUES (1, N'木', N'木三局', 3, 5)
INSERT [dbo].[zWuHang] ([WuHangId], [WuHang], [WuHangJu], [JuShu], [QiZhiId]) VALUES (2, N'火', N'火六局', 6, 10)
INSERT [dbo].[zWuHang] ([WuHangId], [WuHang], [WuHangJu], [JuShu], [QiZhiId]) VALUES (3, N'土', N'土五局', 5, 7)
INSERT [dbo].[zWuHang] ([WuHangId], [WuHang], [WuHangJu], [JuShu], [QiZhiId]) VALUES (4, N'金', N'金四局', 4, 12)
INSERT [dbo].[zWuHang] ([WuHangId], [WuHang], [WuHangJu], [JuShu], [QiZhiId]) VALUES (5, N'水', N'水二局', 2, 2)
SET IDENTITY_INSERT [dbo].[zWuHang] OFF
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (1, 2, 1, 1)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (2, 3, 1, 2)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (3, 4, 1, 3)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (4, 5, 1, 4)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (5, 1, 1, 5)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (6, 3, 2, 1)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (7, 5, 2, 3)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (8, 2, 2, 5)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (9, 4, 2, 2)
INSERT [dbo].[zWuHangGX] ([WuHangGXId], [ZhuTiId], [ShengKeId], [KeTiId]) VALUES (10, 1, 2, 4)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (1, N'子', 1, 5, 23, 1, 1, 10, NULL, NULL, 4, 4)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (2, N'丑', 2, 3, 1, 3, 2, 6, 8, 10, 6, 8)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (3, N'寅', 1, 1, 3, 5, 3, 1, 3, 5, 1, 8)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (4, N'卯', 2, 1, 5, 7, 4, 2, NULL, NULL, 1, 1)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (5, N'辰', 1, 3, 7, 9, 5, 2, 5, 10, 6, 6)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (6, N'巳', 2, 2, 9, 11, 6, 3, 7, 5, 2, 6)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (7, N'午', 1, 2, 11, 13, 7, 4, 6, NULL, 2, 2)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (8, N'未', 2, 3, 13, 15, 8, 2, 6, 4, 6, 7)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (9, N'申', 1, 4, 15, 17, 9, 7, 9, 5, 3, 7)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (10, N'酉', 2, 4, 17, 19, 10, 8, NULL, NULL, 3, 3)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (11, N'戌', 1, 3, 19, 21, 11, 5, 4, 8, 6, 9)
INSERT [dbo].[zZhi] ([ZhiId], [Zhi], [YingYangId], [WuhangId], [FromShi], [ToShi], [ShengXiaoId], [CangGanId1], [CangGanId2], [CangGanId3], [JiJieId], [FangWeiId]) VALUES (12, N'亥', 2, 5, 21, 23, 12, 9, 1, NULL, 4, 9)
ALTER TABLE [dbo].[dMingZhu] ADD  CONSTRAINT [DF_dMingZhu_Disabled]  DEFAULT ((0)) FOR [Disabled]
GO
ALTER TABLE [dbo].[dMingZhu] ADD  CONSTRAINT [DF_dMingZhu_CreateBy]  DEFAULT (suser_sname()) FOR [CreateBy]
GO
ALTER TABLE [dbo].[dMingZhu] ADD  CONSTRAINT [DF_dMingZhu_CreateDateTime]  DEFAULT (getdate()) FOR [CreateDateTime]
GO
ALTER TABLE [dbo].[dMingZhu] ADD  CONSTRAINT [DF_dMingZhu_LastModifiedBy]  DEFAULT (suser_sname()) FOR [LastModifyBy]
GO
ALTER TABLE [dbo].[dMingZhu] ADD  CONSTRAINT [DF_dMingZhu_LastModifyDateTime]  DEFAULT (getdate()) FOR [LastModifyDateTime]
GO
ALTER TABLE [dbo].[dMingZhuSS] ADD  CONSTRAINT [DF_dMingZhuSS_CreateDateTime]  DEFAULT (getdate()) FOR [CreateDateTime]
GO
ALTER TABLE [dbo].[dMingZhuZWAdd] ADD  CONSTRAINT [DF_dMingZhuZWAdd_YueGanId]  DEFAULT ((0)) FOR [YueGanId]
GO
ALTER TABLE [dbo].[dMingZhuZWAdd] ADD  CONSTRAINT [DF_dMingZhuZWAdd_YueZhiId]  DEFAULT ((0)) FOR [YueZhiId]
GO
ALTER TABLE [dbo].[dZiWei] ADD  CONSTRAINT [DF_dZiWei_IsShengGong]  DEFAULT ((0)) FOR [IsShengGong]
GO
ALTER TABLE [dbo].[zSetting] ADD  CONSTRAINT [DF_zSetting_Disabled]  DEFAULT ((0)) FOR [Disabled]
GO
ALTER TABLE [dbo].[zSuanMing] ADD  CONSTRAINT [DF_zSuanMing_SDisabled]  DEFAULT ((0)) FOR [SDisabled]
GO
ALTER TABLE [dbo].[dBaZi]  WITH CHECK ADD  CONSTRAINT [FK_dBaZi_dMingZhu] FOREIGN KEY([MingZhuId])
REFERENCES [dbo].[dMingZhu] ([MingZhuId])
GO
ALTER TABLE [dbo].[dBaZi] CHECK CONSTRAINT [FK_dBaZi_dMingZhu]
GO
ALTER TABLE [dbo].[dBaZi]  WITH CHECK ADD  CONSTRAINT [FK_dBaZi_zGan] FOREIGN KEY([GanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dBaZi] CHECK CONSTRAINT [FK_dBaZi_zGan]
GO
ALTER TABLE [dbo].[dBaZi]  WITH CHECK ADD  CONSTRAINT [FK_dBaZi_zZhi] FOREIGN KEY([ZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[dBaZi] CHECK CONSTRAINT [FK_dBaZi_zZhi]
GO
ALTER TABLE [dbo].[dBaZi]  WITH CHECK ADD  CONSTRAINT [FK_dBaZi_zZhiCGan1] FOREIGN KEY([ZhiCGanId1])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dBaZi] CHECK CONSTRAINT [FK_dBaZi_zZhiCGan1]
GO
ALTER TABLE [dbo].[dBaZi]  WITH CHECK ADD  CONSTRAINT [FK_dBaZi_zZhiCGan2] FOREIGN KEY([ZhiCGanId2])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dBaZi] CHECK CONSTRAINT [FK_dBaZi_zZhiCGan2]
GO
ALTER TABLE [dbo].[dBaZi]  WITH CHECK ADD  CONSTRAINT [FK_dBaZi_zZhiCGan3] FOREIGN KEY([ZhiCGanId3])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dBaZi] CHECK CONSTRAINT [FK_dBaZi_zZhiCGan3]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zGan] FOREIGN KEY([NianGanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zGan]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zGan1] FOREIGN KEY([YueGanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zGan1]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zGan2] FOREIGN KEY([RiGanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zGan2]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zGan3] FOREIGN KEY([ShiGanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zGan3]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zJieQi] FOREIGN KEY([PreviousJieQiId])
REFERENCES [dbo].[zJieQi] ([JieQiId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zJieQi]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zJieQi1] FOREIGN KEY([NextJieQiId])
REFERENCES [dbo].[zJieQi] ([JieQiId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zJieQi1]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zZhi] FOREIGN KEY([NianZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zZhi]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zZhi1] FOREIGN KEY([YueZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zZhi1]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zZhi2] FOREIGN KEY([RiZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zZhi2]
GO
ALTER TABLE [dbo].[dMingZhu]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhu_zZhi3] FOREIGN KEY([ShiZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[dMingZhu] CHECK CONSTRAINT [FK_dMingZhu_zZhi3]
GO
ALTER TABLE [dbo].[dMingZhuAdd]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhuAdd_dMingZhu] FOREIGN KEY([MingZhuId])
REFERENCES [dbo].[dMingZhu] ([MingZhuId])
GO
ALTER TABLE [dbo].[dMingZhuAdd] CHECK CONSTRAINT [FK_dMingZhuAdd_dMingZhu]
GO
ALTER TABLE [dbo].[dMingZhuSS]  WITH CHECK ADD  CONSTRAINT [FK_dMingZhuSS_dMingZhu] FOREIGN KEY([MingZhuId])
REFERENCES [dbo].[dMingZhu] ([MingZhuId])
GO
ALTER TABLE [dbo].[dMingZhuSS] CHECK CONSTRAINT [FK_dMingZhuSS_dMingZhu]
GO
ALTER TABLE [dbo].[dZiWei]  WITH CHECK ADD  CONSTRAINT [FK_dZiWei_dMingZhu] FOREIGN KEY([MingZhuId])
REFERENCES [dbo].[dMingZhu] ([MingZhuId])
GO
ALTER TABLE [dbo].[dZiWei] CHECK CONSTRAINT [FK_dZiWei_dMingZhu]
GO
ALTER TABLE [dbo].[dZiWeiXingYao]  WITH CHECK ADD  CONSTRAINT [FK_dZiWeiXingYao_dZiWei] FOREIGN KEY([ZiWeiId])
REFERENCES [dbo].[dZiWei] ([ZiWeiId])
GO
ALTER TABLE [dbo].[dZiWeiXingYao] CHECK CONSTRAINT [FK_dZiWeiXingYao_dZiWei]
GO
ALTER TABLE [dbo].[dZiWeiXingYao]  WITH CHECK ADD  CONSTRAINT [FK_dZiWeiXingYao_wMiaoXian] FOREIGN KEY([MiaoXianId])
REFERENCES [dbo].[wMiaoXian] ([MiaoXianId])
GO
ALTER TABLE [dbo].[dZiWeiXingYao] CHECK CONSTRAINT [FK_dZiWeiXingYao_wMiaoXian]
GO
ALTER TABLE [dbo].[wGanSiHua]  WITH CHECK ADD  CONSTRAINT [FK_wGanSiHua_wXingYao] FOREIGN KEY([XingYaoId])
REFERENCES [dbo].[wXingYao] ([XingYaoId])
GO
ALTER TABLE [dbo].[wGanSiHua] CHECK CONSTRAINT [FK_wGanSiHua_wXingYao]
GO
ALTER TABLE [dbo].[wGanSiHua]  WITH CHECK ADD  CONSTRAINT [FK_wGanSiHua_zGan] FOREIGN KEY([GanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[wGanSiHua] CHECK CONSTRAINT [FK_wGanSiHua_zGan]
GO
ALTER TABLE [dbo].[wMiaoXianGX]  WITH CHECK ADD  CONSTRAINT [FK_wMiaoXianGX_wXingYao1] FOREIGN KEY([XingYaoId])
REFERENCES [dbo].[wXingYao] ([XingYaoId])
GO
ALTER TABLE [dbo].[wMiaoXianGX] CHECK CONSTRAINT [FK_wMiaoXianGX_wXingYao1]
GO
ALTER TABLE [dbo].[wMiaoXianGX]  WITH CHECK ADD  CONSTRAINT [FK_wMiaoXianGX_zZhi] FOREIGN KEY([ZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[wMiaoXianGX] CHECK CONSTRAINT [FK_wMiaoXianGX_zZhi]
GO
ALTER TABLE [dbo].[wXingYao]  WITH CHECK ADD  CONSTRAINT [FK_wXingYao_wXingYao1] FOREIGN KEY([XingYaoId])
REFERENCES [dbo].[wXingYao] ([XingYaoId])
GO
ALTER TABLE [dbo].[wXingYao] CHECK CONSTRAINT [FK_wXingYao_wXingYao1]
GO
ALTER TABLE [dbo].[zGan]  WITH CHECK ADD  CONSTRAINT [FK_zGan_zGan] FOREIGN KEY([GanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[zGan] CHECK CONSTRAINT [FK_zGan_zGan]
GO
ALTER TABLE [dbo].[zJiaZi]  WITH CHECK ADD  CONSTRAINT [FK_zJiaZi_zGan] FOREIGN KEY([jiaZiGanId])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[zJiaZi] CHECK CONSTRAINT [FK_zJiaZi_zGan]
GO
ALTER TABLE [dbo].[zJiaZi]  WITH CHECK ADD  CONSTRAINT [FK_zJiaZi_zZhi] FOREIGN KEY([JiaZiZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[zJiaZi] CHECK CONSTRAINT [FK_zJiaZi_zZhi]
GO
ALTER TABLE [dbo].[zJieQi]  WITH CHECK ADD  CONSTRAINT [FK_zJieQi_zZhi] FOREIGN KEY([ZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[zJieQi] CHECK CONSTRAINT [FK_zJieQi_zZhi]
GO
ALTER TABLE [dbo].[zWuHang]  WITH CHECK ADD  CONSTRAINT [FK_zWuHang_zZhi] FOREIGN KEY([QiZhiId])
REFERENCES [dbo].[zZhi] ([ZhiId])
GO
ALTER TABLE [dbo].[zWuHang] CHECK CONSTRAINT [FK_zWuHang_zZhi]
GO
ALTER TABLE [dbo].[zZhi]  WITH CHECK ADD  CONSTRAINT [FK_zZhi_zCangGan1] FOREIGN KEY([CangGanId1])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[zZhi] CHECK CONSTRAINT [FK_zZhi_zCangGan1]
GO
ALTER TABLE [dbo].[zZhi]  WITH CHECK ADD  CONSTRAINT [FK_zZhi_zCangGan2] FOREIGN KEY([CangGanId2])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[zZhi] CHECK CONSTRAINT [FK_zZhi_zCangGan2]
GO
ALTER TABLE [dbo].[zZhi]  WITH CHECK ADD  CONSTRAINT [FK_zZhi_zCangGan3] FOREIGN KEY([CangGanId3])
REFERENCES [dbo].[zGan] ([GanId])
GO
ALTER TABLE [dbo].[zZhi] CHECK CONSTRAINT [FK_zZhi_zCangGan3]
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[11] 2[32] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "bz"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 243
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mz"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "gzt"
            Begin Extent = 
               Top = 7
               Left = 291
               Bottom = 168
               Right = 458
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "gss"
            Begin Extent = 
               Top = 7
               Left = 506
               Bottom = 168
               Right = 673
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 329
               Left = 48
               Bottom = 490
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "z"
            Begin Extent = 
               Top = 329
               Left = 273
               Bottom = 490
               Right = 460
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "zcg1"
            Begin Extent = 
               Top = 490
               Left = 48
               Bottom = 651
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' End
         Begin Table = "zcg2"
            Begin Extent = 
               Top = 490
               Left = 273
               Bottom = 651
               Right = 450
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "zcg3"
            Begin Extent = 
               Top = 651
               Left = 48
               Bottom = 812
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "zcgss1"
            Begin Extent = 
               Top = 7
               Left = 721
               Bottom = 168
               Right = 888
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "zcgss2"
            Begin Extent = 
               Top = 7
               Left = 936
               Bottom = 168
               Right = 1103
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "zcgss3"
            Begin Extent = 
               Top = 168
               Left = 342
               Bottom = 329
               Right = 509
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dybz"
            Begin Extent = 
               Top = 168
               Left = 557
               Bottom = 329
               Right = 752
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyg"
            Begin Extent = 
               Top = 168
               Left = 800
               Bottom = 329
               Right = 977
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyz"
            Begin Extent = 
               Top = 168
               Left = 1025
               Bottom = 329
               Right = 1212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyzcg1"
            Begin Extent = 
               Top = 329
               Left = 508
               Bottom = 490
               Right = 685
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyzcg2"
            Begin Extent = 
               Top = 329
               Left = 733
               Bottom = 490
               Right = 910
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyzcg3"
            Begin Extent = 
               Top = 329
               Left = 958
               Bottom = 490
               Right = 1135
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dygss"
            Begin Extent = 
               Top = 490
               Left = 498
               Bottom = 651
               Right = 665
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyzcgss1"
            Begin Extent = 
               Top = 490
               Left = 713
               Bottom = 651
               Right = 880
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyzcgss2"
            Begin Extent = 
               Top = 490
               Left = 928
               Bottom = 651
               Right = 1095
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "dyzcgss3"
            Begin Extent = 
               Top =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane3', @value=N' 651
               Left = 273
               Bottom = 812
               Right = 440
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 39
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=3 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[12] 4[4] 2[56] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -360
         Left = 0
      End
      Begin Tables = 
         Begin Table = "mz"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 294
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "bz1"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "bz2"
            Begin Extent = 
               Top = 168
               Left = 270
               Bottom = 329
               Right = 444
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "bz3"
            Begin Extent = 
               Top = 329
               Left = 48
               Bottom = 490
               Right = 222
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "bz4"
            Begin Extent = 
               Top = 329
               Left = 270
               Bottom = 490
               Right = 444
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "bz5"
            Begin Extent = 
               Top = 367
               Left = 492
               Bottom = 528
               Right = 687
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 148
         Width = 284
         Width = 1332
         Width = 1200
         Width = 1200
  ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZiSS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'       Width = 1296
         Width = 2208
         Width = 1992
         Width = 1200
         Width = 1020
         Width = 1380
         Width = 672
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1572
         Width = 1200
         Width = 1608
         Width = 1368
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZiSS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vBaZiSS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[22] 4[17] 2[36] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "jz"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 214
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 7
               Left = 262
               Bottom = 168
               Right = 439
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "z"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ny"
            Begin Extent = 
               Top = 7
               Left = 487
               Bottom = 168
               Right = 648
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vJiaZi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vJiaZi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[5] 4[19] 2[45] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = -960
         Left = 0
      End
      Begin Tables = 
         Begin Table = "mz"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 299
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g1"
            Begin Extent = 
               Top = 7
               Left = 347
               Bottom = 168
               Right = 524
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g2"
            Begin Extent = 
               Top = 7
               Left = 572
               Bottom = 168
               Right = 749
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g3"
            Begin Extent = 
               Top = 7
               Left = 797
               Bottom = 168
               Right = 974
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g4"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "z1"
            Begin Extent = 
               Top = 168
               Left = 273
               Bottom = 329
               Right = 460
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "z2"
            Begin Extent = 
               Top = 168
               Left = 508
               Bottom = 329
               Right = 695
            End
            DisplayFlags = 280
            TopColumn = 0
        ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMingZhu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' End
         Begin Table = "z3"
            Begin Extent = 
               Top = 168
               Left = 743
               Bottom = 329
               Right = 930
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "z4"
            Begin Extent = 
               Top = 329
               Left = 48
               Bottom = 490
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "cjq"
            Begin Extent = 
               Top = 168
               Left = 978
               Bottom = 329
               Right = 1157
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pjq"
            Begin Extent = 
               Top = 329
               Left = 283
               Bottom = 490
               Right = 462
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "njq"
            Begin Extent = 
               Top = 329
               Left = 510
               Bottom = 490
               Right = 689
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mza"
            Begin Extent = 
               Top = 329
               Left = 737
               Bottom = 490
               Right = 954
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mzza"
            Begin Extent = 
               Top = 329
               Left = 1002
               Bottom = 446
               Right = 1176
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "wh"
            Begin Extent = 
               Top = 448
               Left = 1002
               Bottom = 609
               Right = 1175
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "yg"
            Begin Extent = 
               Top = 490
               Left = 48
               Bottom = 651
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "yz"
            Begin Extent = 
               Top = 490
               Left = 273
               Bottom = 651
               Right = 460
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sh"
            Begin Extent = 
               Top = 967
               Left = 48
               Bottom = 1128
               Right = 209
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 20
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1464
         Width = 1200
         Width = 2208
         Width = 2652
         Width = 1200
         Width = 2808
         Width = 2400
         Width = 2220
         Width = 1524
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy =' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMingZhu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane3', @value=N' 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMingZhu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=3 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMingZhu'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[41] 4[20] 2[32] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "mzss"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 261
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ss"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 215
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "gzt"
            Begin Extent = 
               Top = 168
               Left = 263
               Bottom = 329
               Right = 430
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mz"
            Begin Extent = 
               Top = 7
               Left = 309
               Bottom = 168
               Right = 555
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMingZhuSS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMingZhuSS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "yz"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sz"
            Begin Extent = 
               Top = 168
               Left = 283
               Bottom = 329
               Right = 470
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mgz"
            Begin Extent = 
               Top = 329
               Left = 48
               Bottom = 490
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sgz"
            Begin Extent = 
               Top = 329
               Left = 283
               Bottom = 490
               Right = 470
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "t"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 245
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 11
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
      ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMSGongWei'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'   Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMSGongWei'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vMSGongWei'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[21] 4[4] 2[41] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "g1"
            Begin Extent = 
               Top = 7
               Left = 260
               Bottom = 168
               Right = 437
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g2"
            Begin Extent = 
               Top = 7
               Left = 485
               Bottom = 168
               Right = 662
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "yg"
            Begin Extent = 
               Top = 7
               Left = 710
               Bottom = 168
               Right = 887
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "yz"
            Begin Extent = 
               Top = 7
               Left = 935
               Bottom = 168
               Right = 1122
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ny"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 212
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vNianToYue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N' = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vNianToYue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vNianToYue'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[19] 4[4] 2[62] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "t"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 221
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g1"
            Begin Extent = 
               Top = 7
               Left = 269
               Bottom = 168
               Right = 446
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g2"
            Begin Extent = 
               Top = 7
               Left = 494
               Bottom = 168
               Right = 671
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vRiToShi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vRiToShi'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[22] 4[4] 2[44] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "zw"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "mz"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 329
               Right = 299
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "gw"
            Begin Extent = 
               Top = 7
               Left = 298
               Bottom = 168
               Right = 465
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "g"
            Begin Extent = 
               Top = 329
               Left = 289
               Bottom = 490
               Right = 466
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "z"
            Begin Extent = 
               Top = 490
               Left = 48
               Bottom = 651
               Right = 235
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hlxy"
            Begin Extent = 
               Top = 651
               Left = 48
               Bottom = 790
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hlgw"
            Begin Extent = 
               Top = 7
               Left = 513
               Bottom = 168
               Right = 680
            End
            DisplayFlags = 280
            TopColumn = 0
         ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vZiWeiGW'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'End
         Begin Table = "hqxy"
            Begin Extent = 
               Top = 952
               Left = 48
               Bottom = 1091
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hqgw"
            Begin Extent = 
               Top = 7
               Left = 728
               Bottom = 168
               Right = 895
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hkxy"
            Begin Extent = 
               Top = 1253
               Left = 48
               Bottom = 1392
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hkgw"
            Begin Extent = 
               Top = 7
               Left = 943
               Bottom = 168
               Right = 1110
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hjxy"
            Begin Extent = 
               Top = 1554
               Left = 48
               Bottom = 1693
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "hjgw"
            Begin Extent = 
               Top = 168
               Left = 347
               Bottom = 329
               Right = 514
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 39
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 3060
         Width = 1200
         Width = 1200
         Width = 3312
         Width = 1992
         Width = 1680
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1776
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1632
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vZiWeiGW'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vZiWeiGW'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[18] 4[15] 2[33] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "zw"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 168
               Right = 250
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "zwxy"
            Begin Extent = 
               Top = 168
               Left = 48
               Bottom = 307
               Right = 225
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "xy"
            Begin Extent = 
               Top = 308
               Left = 48
               Bottom = 447
               Right = 253
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "xyt"
            Begin Extent = 
               Top = 7
               Left = 551
               Bottom = 168
               Right = 718
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 36
         Width = 284
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1368
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 12' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vZiWeiXY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'00
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
         Width = 1200
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1176
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1356
         SortOrder = 1416
         GroupBy = 1350
         Filter = 1356
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vZiWeiXY'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vZiWeiXY'
GO
