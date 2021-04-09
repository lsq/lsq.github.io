require "mechanize"
require "open-uri"
require "aria2"

target_site = 'target_site'
target_url = 'http://www.baoan.gov.cn/rlzyj/zwgk/tzgg/index.html'
# create a client instance
client = Aria2::Client.new(host: 'localhost', port: 6800)
$queue=[]
$queueFile=[]
$queue.push({target_site => target_url})
=begin 
    下载所有文件的思路：
    有一个入口的URl，和一个队列，队列中最开始只有一个此入口url，
    根据这个url，获取此页面的所有链接，把链接放到队列中，同时过滤出来 需要的表格url，把表格url保存下来。
    
=end
    
    
    # queue对列中放的是一个 {网页标题 => 网页url } 的散列
while !$queue.empty?
    url=""
    $queue.shift.each_value do |value|
        url=value
    end
   begin
    page=Mechanize.new.get(url)
   rescue 
       puts "---------------------->>>>  #{url} 不能访问"
   end
   
    page.links.each do |link|
        if link.text.include?('.xls')# 将有用的表格url存起来
            puts link.text
            $queueFile.push({link.text => link.href})
        elsif link.text.include?('“以工代训”补贴名单公示') || link.text.include?('下一页')# 有用的链接放到队列中，便于下一次访问
            #puts link.text
            $queue.push({link.text=>link.href})
        end
    end
end

# 根据 url 下载到本地
while !$queueFile.empty?
    url=$queueFile.shift
    url.each do |key,value|
        puts key
        puts "--#{value}"
        #File.open('./'+key,"w") do |io|
        #  io.puts(open(value).read)
        #end
        client.addUri value
    end
end
