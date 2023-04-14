<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<!-- 论坛中心 -->
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
		<title>论坛中心</title>
		<link rel="stylesheet" href="../../layui/css/layui.css">
		<!-- 样式 -->
		<link rel="stylesheet" href="../../css/style.css" />
		<!-- 主题（主要颜色设置） -->
		<link rel="stylesheet" href="../../css/theme.css" />
		<!-- 通用的css -->
		<link rel="stylesheet" href="../../css/common.css" />
	</head>
	<body>

		<div id="app">

			<!-- 轮播图 -->
			<div class="layui-carousel" id="swiper">
				<div carousel-item id="swiper-item">
					<div v-for="(item,index) in swiperList" v-bind:key="index">
						<img class="swiper-item" :src="item.img">
					</div>
				</div>
			</div>
			<!-- 轮播图 -->

			<!-- 标题 -->
			<h2 class="index-title">FORUM / INFORMATION</h2>
			<div class="line-container">
				<p class="line"> 我的发布 </p>
			</div>
			<!-- 标题 -->

			<!-- banner -->
			<div class="banner"></div>
			<!-- banner -->

			<div class="forum-container">
				<table class="layui-table" lay-skin="nob">
					<thead>
						<tr>
							<th>标题</th>
							<th>发布时间</th>
							<th>操作</th>
						</tr>
					</thead>
					<tbody>
						<tr v-for="(item,index) in dataList" v-bind:key="index">
							<td @click="jump('../forum/detail.jsp?id='+item.id);">{{item.title}}</td>
							<td>{{item.addtime}}</td>
							<td>
								<button @click="jump('../forum/update.jsp?id='+item.id);" type="button" class="layui-btn layui-btn-radius btn-warm">
									修改
								</button>
								<button @click="deleteClick(item.id)" type="button" class="layui-btn layui-btn-radius btn-theme">
									删除
								</button>
							</td>
						</tr>
					</tbody>
				</table>
				<div class="pager" id="pager"></div>
			</div>
			
		</div>

		<!-- layui -->
		<script src="../../layui/layui.js"></script>
		<!-- vue -->
		<script src="../../js/vue.js"></script>
		<!-- 组件配置信息 -->
		<script src="../../js/config.js"></script>
		<!-- 扩展插件配置信息 -->
		<script src="../../modules/config.js"></script>
		<!-- 工具方法 -->
		<script src="../../js/utils.js"></script>

		<script>
			var vue = new Vue({
				el: '#app',
				data: {
					// 轮播图
					swiperList: [{
						img: '../../img/banner.jpg'
					}],
					dataList: []
				},
				filters: {
					newsDesc: function(val) {
						if (val) {
							if (val.length > 200) {
								return val.substring(0, 200).replace(/<[^>]*>/g).replace(/undefined/g, '');
							} else {
								return val.replace(/<[^>]*>/g).replace(/undefined/g, '');
							}
						}
						return '';
					}
				},
				methods: {
					jump(url) {
						jump(url)
					},
					deleteClick(id) {
						layui.layer.confirm('是否确认删除？', {
							btn: ['删除', '取消'] //按钮
						}, function() {
							layui.http.requestJson(`forum/delete`, 'post', [id], function(res) {
								layer.msg('删除成功', {
									time: 2000,
									icon: 6
								}, function(res) {
									window.location.reload();
								});
							})
						});
					}
				}
			})

			layui.use(['layer', 'element', 'carousel', 'laypage', 'http', 'jquery'], function() {
				var layer = layui.layer;
				var element = layui.element;
				var carousel = layui.carousel;
				var laypage = layui.laypage;
				var http = layui.http;
				var jquery = layui.jquery;

				var limit = 10;

				// 获取轮播图 数据
				http.request('config/list', 'get', {
					page: 1,
					limit: 5
				}, function(res) {
					if (res.data.list.length > 0) {
						var swiperItemHtml = '';
						for (let item of res.data.list) {
							if (item.name.indexOf('picture') >= 0 && item.value && item.value != "" && item.value != null) {
								swiperItemHtml +=
									'<div>' +
									'<img class="swiper-item" src="' + item.value + '">' +
									'</div>';
							}
						}
						jquery('#swiper-item').html(swiperItemHtml);
						// 轮播图
						carousel.render({
							elem: '#swiper',
							width: swiper.width,height:swiper.height,
							arrow: swiper.arrow,
							anim: swiper.anim,
							interval: swiper.interval,
							indicator: swiper.indicator
						});
					}
				});

				// 获取列表数据
				http.request('forum/page?parentid=0&sort=addtime&order=desc', 'get', {
					page: 1,
                    limit: limit
				}, function(res) {
					vue.dataList = res.data.list
					// 分页
					laypage.render({
						elem: 'pager',
						count: res.data.total,
                        limit: limit,
						jump: function(obj, first) {
							//首次不执行
							if (!first) {
								http.request('forum/page?parentid=0&sort=addtime&order=desc', 'get', {
									page: obj.curr,
									limit: obj.limit
								}, function(res) {
									vue.dataList = res.data.list
								})
							}
						}
					});
				})

			});
		</script>
	</body>
</html>
