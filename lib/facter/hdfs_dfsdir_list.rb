# hdfs_dfsdir_list.rb
#
# Returns list of paths suitable for dfs storage
# to put into hdfs-site.xml->dfsdir
#


Facter.add("hdfs_dfsdir_list") do
	setcode do
		#Dir['/hadoop-data*'].join(',')
		# Ruby calls stat() on entries and doesn't return them if the
		# call fails. We want to keep failed mount points in the list.
		Dir.entries('/').
			sort.
			select { |str| str.start_with?("hadoop-data") }.
			map { |str| 'file:///' + str }.
			join(',')
	end
end

