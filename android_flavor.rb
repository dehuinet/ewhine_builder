require 'yaml'

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
