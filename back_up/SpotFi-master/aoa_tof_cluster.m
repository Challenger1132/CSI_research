%{
关于聚类的相关函数
pdist函数：计算矩阵X各行之间的距离，注意第二个参数使求解按照某种算法进行，如欧式距离、名氏距离等等
是矩阵两行之间的距离
d = pdist(X); 得到的是一个矩阵各行之间的一个行向量，还可以添加一个参数，按照某种算法求两个向量之间的距离
dm = squareform(d); 将距离向量变换为距离矩阵的形式，距离矩阵是一个实对称矩阵
dd = tril(dm); 距离矩阵变换为上三角的形式
lk = linkage(d); linkage函数的到系统聚类树，要用到pdist的结果，注意这里也有一个参数，计算的是类间距离
dg = dendrogram(lk, d); 得到谱系聚类图,如果d小于30可以省略
cc = cluster(lk, k); linkage的结果传给cluster函数进行聚类，k是聚类数目
ch = cophenent(lk, d); 利用pdist函数生成的d和linkage函数生成的lk计算相关系数
选择样本之间(矩阵的某一行)不同的距离算法，不同的类间距离算法，如何评估聚类的效果呢？
用cophenent函数求复合相关系数 越接近1 聚类效果越理想

对linkage函数返回结果的分析：
对于原始矩阵X，共M行(M个样本)，用pdist函数计算，返回一个 M*(M-1)/2的行向量
(每一个元素是各行之间的距离， M*(M-1)/2代表各行之间的组合数)
linkage函数返回结果lk则是(M-1)*3的矩阵,lk矩阵的前两列是索引下标列，
代表矩阵X中哪两行应该聚类到一起，也就是表示哪两个序号的样本可以聚为同一类，第三列为这两个样本之间的距离
除了M个样本以外，对于每次新产生的类，依次用M+1、M+2、…来标识

lk = linkage(d)
lk =
     3.0000     4.0000     0.2228
     2.0000     5.0000     0.5401
     1.0000     7.0000     1.0267
     6.0000     9.0000     1.0581
     8.0000    10.0000     1.3717
上例中表示在产生聚类树的计算过程中，第3和第4点先聚成一类，他们之间的距离是0.2228，
以此类推。要注意的是，为了标记每一个节点，需要给新产生的聚类也安排一个标识，MATLAB中
会将新产生的聚类依次用M+1,M+2,....依次来标识。比如第3和第4点聚成的类以后就用7来标识，
第2和第5点聚成的类用8来标识，依次类推。通过linkage函数计算之后，实际上二叉树式的聚类已经完成了
lk这个数据数组不太好看，可以用dendrogram(lk)来可视化聚类树
%}
function [cluster_indices,clusters] = aoa_tof_cluster(full_measurement_matrix)
    % 将若干数据包中的AOA TOF数据放到full_measurement_matrix矩阵中,对其进行聚类
	% 目的是将来自不同数据包的但同一路径的AOA TOF聚到一类
	linkage_tree = linkage(full_measurement_matrix, 'ward');   % (m – 1)-by-3
	% 生成系统聚类树 linkage_tree 是size(full_measurement_matrix)-1 * 3 的矩阵
	% ward代表采用 最小方差算法
    % cluster_indices_vector = cluster(linkage_tree, 'CutOff', 0.45, 'criterion', 'distance');
    % cluster_indices_vector = cluster(linkage_tree, 'CutOff', 0.85, 'criterion', 'distance');
    cluster_indices_vector = cluster(linkage_tree, 'CutOff', 1.0, 'criterion', 'distance');
	% cluster_indices_vector 中的最大值不会超过cluster_count_vector的行数
	% cluster_indices_vector 返回的是聚类的下标
	% cluster_indices_vector(i) = k表示第i个元素被划分到第k个聚类中，元素的种类数就是聚类数目
    cluster_count_vector = zeros(0, 1);
    num_clusters = 0;
    for ii = 1:size(cluster_indices_vector, 1) % cluster_indices_vector 是size(full_measurement_matrix)大小的列向量
        if ~ismember(cluster_indices_vector(ii), cluster_count_vector)
            cluster_count_vector(size(cluster_count_vector, 1) + 1, 1) = cluster_indices_vector(ii);
            num_clusters = num_clusters + 1;
        end
    end % 找cluster_indices_vector中不同元素的数目，也就是确定聚类数目num_clusters
	
    % Collect data and indices into cluster-specific cell arrays
    clusters = cell(num_clusters, 1);
    cluster_indices = cell(num_clusters, 1);
    for ii = 1:size(cluster_indices_vector, 1)
        % Save off the data
        tail_index = size(clusters{cluster_indices_vector(ii, 1)}, 1) + 1;
		% 在clusters代表的若干[]中找第cluster_indices_vector(ii, 1)个[]，
		% tail_index是在clusters中确定的[]的行数+1
        clusters{cluster_indices_vector(ii, 1)}(tail_index, :) = full_measurement_matrix(ii, :);
		% 将full_measurement_matrix(ii, :)代表的 AOA TOF数据，存到第cluster_indices_vector(ii, 1)个[]的第tail_index行中
        % Save off the indexes for the data
        cluster_index_tail_index = size(cluster_indices{cluster_indices_vector(ii, 1)}, 1) + 1;
        cluster_indices{cluster_indices_vector(ii, 1)}(cluster_index_tail_index, 1) = ii;
		% 同上存储下标ii
    end
	% clusters中存放了已经聚类好的AOA TOF数据，不同的聚类放在clusters中不同的cell中
	% cluster_indices存储了对应聚类的下标
end
