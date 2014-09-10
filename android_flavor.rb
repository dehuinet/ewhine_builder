require 'yaml'
require 'ox'
require 'pry'
require 'fileutils'
root=ARGV[0]
flavor_name=ARGV[1]
version_code=ARGV[2]
version_name=ARGV[3]

if root.nil? then
	puts "need root path"
	return
end

flavors=flavor_name.split(",")

plugins_path = "#{root}/enterprise_micro_blog/flavors/#{flavors[0]}/plugins"


dependencies = "compile fileTree(dir: 'libs', include: '*.jar')\n"
manifest_srcFile =''
if File.exist?plugins_path
  #如果有插件 要创建一个settings.gradle 文件
  setting = ''
  Dir.open(plugins_path) do |d| 
    d.each do |x| 
      if !(x.start_with? '.') 
        setting << "include '#{x}'" << "\n"
        dependencies << "compile project(\":#{x}\")" << "\n"
        manifest_srcFile << "manifest.srcFile 'flavors/#{flavors[0]}/plugins/#{x}/AndroidManifest.xml'" <<"\n"
      end
    end
    d.each do |x| 
      if !(x.start_with? '.') 
        setting << "project(':#{x}').projectDir = new File('flavors/#{flavors[0]}/plugins/#{x}')" << "\n"
      end
    end
  end
  puts setting
  File.open("#{root}/enterprise_micro_blog/settings.gradle","w"){|f| f.write setting}
end 
dependencies << "}"

product_flavors="productFlavors {"

source_sets = %q{
	sourceSets \{
		main \{
			manifest.srcFile 'AndroidManifest.xml'
			java.srcDirs = ['src']
			resources.srcDirs = ['src']
			aidl.srcDirs = ['src']
			renderscript.srcDirs = ['src']
			res.srcDirs = ['res']
			assets.srcDirs = ['assets']
			\}
		}




		flavors.each do|flavor|

			product_flavors << %Q{
				#{flavor} {
				packageName="com.minxing.#{flavor}"
			}
		}

		source_sets << %Q{
			#{flavor}{
			res.srcDirs = ['flavors/#{flavor}/res']
			#{manifest_srcFile}
		}
	}

end

product_flavors << "}"

source_sets << " instrumentTest.setRoot('tests')\n}"


gradle_file="#{root}/enterprise_micro_blog/build.gradle"

gradle_file_content=File.read(gradle_file)

gradle_file_content.gsub!(/compile fileTree.*?\([\s\S]*?\)[\s\S]*?\}/,dependencies)
gradle_file_content.gsub!(/productFlavors.*?\{[\s\S]*?\}\s*?\}/,product_flavors)
gradle_file_content.gsub!(/sourceSets.*?\{[\s\S]*?instrumentTest[\s\S]*?\}/,source_sets)
gradle_file_content.gsub!(/versionCode.*\n/,"versionCode #{version_code}\n")
gradle_file_content.gsub!(/versionName.*\n/,"versionName \"#{version_name}\"\n")

File.open(gradle_file, 'w') { |file| file.write(gradle_file_content) }

build_file="#{root}/enterprise_micro_blog/flavors/#{flavors.first}/build.yaml" 
if File.exists? build_file then
puts build_file
	build_config=YAML::load(File.read(build_file))
	manifest_file="#{root}/enterprise_micro_blog/AndroidManifest.xml"

	manifest_object = Ox.parse(File.read(manifest_file))
	meta_objects=manifest_object.locate("application/meta-data")
	meta_objects.each do|meta|
		name=meta[:"android:name"]
		puts build_config
		puts build_config[name]
		if build_config[name] then
			meta[:"android:value"]=build_config[name]
		end
	end
	File.open(manifest_file, 'w') { |file| file.write( Ox.dump(manifest_object)) }
end

#copy jar 一共6层循环 其实是3层 每次目录遍历都得带两层循环 ruby就这样 
#第一（二）层循环 负责遍历插件plugins目录里有几个插件 第三（四）层循环负责遍历插件工程的libs下的所有jar 第五（六）层循环负责对比这些jar的去除版本信息后时候在主工程里有相同的jar 如果有就不copy了
if File.exist?plugins_path
	Dir.open(plugins_path) do |d| 
    	d.each do |x| 
    		if !(x.start_with? '.') 
      		libs_path = "#{plugins_path}/#{x}/libs"
      		if File.exist?libs_path
      			Dir.open(libs_path) do |dir|
      				dir.each do |jar|
      				  copyOK = true
      					if !(jar.start_with? '.') && !(File.exist?"#{root}/enterprise_micro_blog/libs/#{jar}")
      					   m = /-v[0-9]*.jar/.match jar
      					   if !m.nil?
      					     #如果插件工程的jar包的名字带类似 xxxx-v4.jar一类的样子 就要注意主工程里是不是也有类似的jar 如果有也不能copy
                      pre = m.pre_match
                      Dir.open("#{root}/enterprise_micro_blog/libs") do |m_d|
                        m_d.each do |m_jar|
                          #这是minxing主工程里得jar列表
                          if !(/#{pre}/.match m_jar).nil?
                            #进去这个逻辑 说明是匹配了 如果匹配了 说明主工程里有类似的jar 就不copy了
                            copyOK = false
                            puts "注意：#{jar} 由于主程序目录已经存在完全同名文件或者同名不同版本的文件，因此不进行copy操作"
                            break
                          end
                        end
                      end
      					   end
      					  if !copyOK
      					    next
      					  end
      						FileUtils.copy "#{libs_path}/#{jar}","#{root}/enterprise_micro_blog/libs/#{jar}"
      					end
      				end
      			end
      		end
    	  end
    	end
    end
end