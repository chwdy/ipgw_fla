if (aa.data.exist != 1) { 
  aa.data.exist = 1 
  aa.data.uid = ""//新版本中为username 
  aa.data.password = "" 
  aa.data.savename = true 
  aa.data.savepass = false 
  aa.data.saveshow = false 
  aa.flush() 
} 
 
if(aa.data.version  == undefined){ 
  aa.data.version = 201604181 
  aa.data.show_usage = 0 
  aa.flush() 
} 

if(aa.data.version  < 201609152){ 
  aa.data.version = 201609152 
  aa.flush() 
} 
if(aa.data.version  < 201609171){ 
  aa.data.version = 201609171 
  aa.flush() 
} 
if(aa.data.version  < 201609172){ 
  aa.data.version = 201609172
  aa.flush() 
} 
if(aa.data.version  < 201609173){ 
  aa.data.version = 201609173
  aa.flush() 
} 