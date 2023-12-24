### RabbitMQ

#### 相关文档
[官方文档](https://www.rabbitmq.com/documentation.html)
[RabbitMQ集群方案的原理](https://www.cnblogs.com/xishuai/p/rabbitmq-cluster.html)
[集群](http://www.cnblogs.com/flat_peach/archive/2013/04/07/3004008.html)
[RabbitMQk由浅入深](https://pdf.us/tag/rabbitmq)
[AMQP-0-9-1中文规范](http://www.blogjava.net/qbna350816/archive/2016/08/12/431554.html)

#### 介绍
```
rabbitmq 是基于 AMQP 协议的开源的重型的消息队列工具, 基于 Erlang语言编写。
rabbitmq 除了基本的消息队列功能，还实现了可伸缩集群，消息持久化等功能

Exchange 4种类型的效率比较：fanout > direct > topic > header
```

#### 规范

1. 所有的队列，均使用镜像模式，至少一个 disc 节点，一个ram节点

2. 代码中不自动创建/修改队列，路由，交换器
```
RabbitMQ 是重型消息队列工具，在队列，路由，交换器上有很多属性，用于业务的管理
由程序自动创建，易将很多属性写死，帯来不必要的问题
因此所有的创建，修改全部由管理后台完成
```
3. 程序中只负责收发消息

4. 所有的消息发送要确认

5. 所有的消息接收，处理完成后要确认

6. 核心业务优先使用 Fanout 交换器 

7. 日志相关业务优先使用 topic 交换器 

8. exchange 永不使用 header 类型
```
可通过 topic 类型实现类似的功能，写在 header 里，维护性很差
```

9. topic 交换器要指定死信队列

10. 消息长度不要超过4M，否则会严重影响性能


#### 部署方式

* 单机模式
```
直接部署，默认为 disc 节点，最简单
```

* 集群模式
```
集群指多个节点，集合在一超，队列的数据中放在一个节点上了，所以集群并不是高可用
连接到集群上的任何一个节点，均可以实现队列的收发
集群内部的节点保存了全部的元数据，任何的消息发来均知道数据应保存在那里，并实现了转发
```

* 镜像模式
```
镜像模式是在集群模式的基础上，添加队列复制策略实现的
镜像模式可以实现1 disc节点 1 ram节点, 1 disc节点 N ram节点，N disc节点，N ram节点
```

#### 策略
```
rabbitmqctl set_policy [-p Vhost] Name Pattern Definition [Priority]

-p Vhost： 可选参数，针对指定vhost下的queue进行设置
Name: policy的名称
Pattern: queue的匹配模式(正则表达式)
Definition：镜像定义，包括三个部分ha-mode, ha-params, ha-sync-mode
	ha-mode:指明镜像队列的模式，有效值为 all/exactly/nodes
		all：表示在集群中所有的节点上进行镜像
		exactly：表示在指定个数的节点上进行镜像，节点的个数由ha-params指定
		nodes：表示在指定的节点上进行镜像，节点名称通过ha-params指定
	ha-params：ha-mode模式需要用到的参数
	ha-sync-mode：进行队列中消息的同步方式，有效值为automatic和manual
priority：可选参数，policy的优先级

rabbitmqctl set_policy --priority 0 --apply-to queues mirror_queue "^queue_" '{"ha-mode":"exactly","ha-params":2,"ha-sync-mode":"automatic"}'
```

##### 常用操作
```
#添加虚拟机
rabbitmqctl add_vhost vhost 

#列出所有虚拟主机
rabbitmqctl list_vhosts

#删除虚拟主机
rabbitmqctl delete_vhost vhostpath



#添加用户密码
rabbitmqctl add_user username password

#列出所有用户
rabbitmqctl list_users

#改用户密码
rabbimqctl change_password username newpassword

#删除用户
rabbitmqctl delete_user username



#列出用户权限
rabbitmqctl list_user_permissions username

#列出虚拟主机上的所有权限
rabbitmqctl list_permissions -p vhost

#Tags 可以是：administrator, monitoring, management
rabbitmqctl set_user_tags username administrator

#后边三个.*分别代表：配置权限、写权限、读权限
rabbitmqctl set_permissions -p vhostname username ".*" ".*" ".*"

#清除用户权限
rabbitmqctl clear_permissions -p vhostpath username


#关闭应用（关闭当前启动的节点）
rabbitmqctl stop_app

#启动应用，和上述关闭命令配合使用，达到清空队列的目的
rabbitmqctl start_app

#从管理数据库中移除所有数据，例如配置过的用户和虚拟宿主, 删除所有持久化的消息（这个命令要在rabbitmqctl stop_app之后使用）
rabbitmqctl reset

#作用和rabbitmqctl reset一样，区别是无条件重置节点，不管当前管理数据库状态以及集群的配置。如果数据库或者集群配置发生错误才使用这个最后的手段
rabbitmqctl force_reset

#节点状态
rabbitmqctl status


#查看所有队列信息
rabbitmqctl list_queues

#清除队列里的消息
rabbitmqctl -p vhostpath purge_queue blue
```

系统调优
```
vm_memory_high_watermark,0.6
{hipe_compile, true}
```

#### 镜像队列 配置方法
```
镜像队列主要是通过添加相应policy的方式完成
rabbitmqctl set_policy [-p vhost] [--priority priority] [--apply-to apply-to] {name} {pattern} {definition}
对于镜像队列，definition部分包含3个部分：ha-mode、ha-params、ha-sync-mode
ha-mode，镜像队列模式，值有all、exactly、nodes，默认为all
->all，在集群中所有节点上进行镜像
->exactly，在指定个数的节点上进行镜像，节点个数由ha-params指定
->nodes，在指定节点上进行镜像，节点名称通过ha-params指定，节点名称可以通过rabbitmqctl cluster_status命令查看
ha-params，不同ha-mode配置中需要用到的参数
ha-sync-mode，队列中消息的同步方式，值有automatic、manual
对名称以queue_开头的所有队列进行镜像，并在集群的两个节点上完成镜像

rabbitmqctl -n rabbit0 set_policy --priority 0 --apply-to queues mirror_queue "^m" '{"ha-mode":"all","ha-sync-mode":"automatic"}'

ha-mode对排他exclusive队列无效，因为排他队列是独占的，当连接断开时会自动删除

ha-sync-mode为manual时，新加入的节点不会主动同步到新的slave中，需要显式调用同步命令
ha-sync-mode为automatic时，新加入的slave会自动同步已知镜像队列
同步时，队列会阻塞，直至同步完成，所以不建立对生产环境正在使用的队列进行操作
手动同步队列：rabbitmqctl sync_queue queue_test

当ha-promote-on-shutdown设置为when-synced(默认)时，若master主动停掉，如rabbitmqctl stop或者优雅关闭操作系统，那么slave不会接管master，镜像队列不可用；
如果master因被动原因关掉，如Erlang虚拟机或操作系统崩溃，slave会接管master；
若ha-promote-on-shutdown设置为always，那么slave总是会接替master，优先保证可用性，不过过程中可能会有消息丢失

镜像队列最后一个停止的会是master，要恢复镜像队列，可以尝试在30秒内启动所有节点

若消息是持久化的，建议搭配惰性队列使用
```


#### 问题

* 集群中部分节点出现 "Node statistics not available"
```
这是因为web管理工具中的 rabbitmq_management 插件未启用, 执行如下命令：
rabbitmq-plugins enable rabbitmq_management
集群中每个节点均要开启 rabbitmq_management 插件
```

* 消息体长度
```
最好不要超过4M
```

* 任务执行顺序
```
worker在执行任务时，时间长短不定，故不能保证队列的顺序
如果要保证严格的时序，请在消息体内自行加上全局自增ID
```

* 重试
```
RabbitMQ 没有自帯的重试机制，但有延迟执行的功能，可以结合代码变相实现
```

* 消息确认
```
RabbitMQ 的消息确认是异歩的，一定要确认，才可以保证高可用

确认
不确认
明确拒绝
```

* 死信队列DLX
```
topic 交换器的消息，在发送时，如果没有匹配到队列，则发到死信队列
```

* 优化级
```
#x-max-priority
RabbitMQ 支持了队列优先级和消息优先级
```
