validate the **virtualmachine** connectivity with **log analytics workspace**

![1](https://user-images.githubusercontent.com/57703276/181075209-4ebb8c75-c722-496e-a5df-c5bda7842776.png)

select a **scope**

![2](https://user-images.githubusercontent.com/57703276/181075949-8c869a62-e1ff-4ce5-afa1-e080ce787c14.png)


select a resource under scope 

![3](https://user-images.githubusercontent.com/57703276/181075743-007d5a94-bceb-45b3-8f21-980a2532c2ea.png)


prepare the KSQL query

In this case i am trying to find the dodo-vm2 machine heardbeats use ksql query

```sql
Heartbeat
| where Computer contains "dodo-vm2"
```

execute the **KSQL** query 

![4](https://user-images.githubusercontent.com/57703276/181076265-2b3a2177-19ad-4162-98c8-f4606cd25286.png)
