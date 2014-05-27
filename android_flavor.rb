require 'yaml'
require 'ox'
require 'pry'
root=ARGV[0]
flavor_name=ARGV[1]
version_code=ARGV[2]
version_name=ARGV[3]

if root.nil? then
	puts "need root path"
	return
end
flavors=flavor_name.split(",")

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
		}
	}

end

product_flavors << "}"

source_sets << " instrumentTest.setRoot('tests')\n}"


gradle_file="#{root}/enterprise_micro_blog/build.gradle"

gradle_file_content=File.read(gradle_file)

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