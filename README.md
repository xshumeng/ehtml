# EHTML
基于mochiweb的mochiweb_html模块实现通过选择器定位并获取HTML文档内的指定节点。

# 配置
由于工具是基于mochiweb构建，所以使用时必须保证当前ERLANG虚拟机中包含了
mochiweb_html模块。

# 使用
支持的选择器有：标签选择器、ID选择器、类选择器

``` erlang
    {ok, FileBin} = file:read_file(Page),
    HNode = html_util:parse(FileBin),
    %% 定义HTML选择器
    Selector = "html body #content .dict_nav_list ul li a",
    %% 获取指定选择器的节点
    Ret = html_util:get_by_selector(Selector, HNode),
    %% 获取节点的属性
    html_util:get_attrs_value("href", Ret)
```
