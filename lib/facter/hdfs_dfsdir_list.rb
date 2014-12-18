# hdfs_dfsdir_list.rb
#
# Returns list of paths suitable for dfs storage
# to put into hdfs-site.xml->dfsdir
#


Facter.add("hdfs_dfsdir_list") do
	setcode do
		Dir['/hadoop-data*'].join(',')
	end
end

