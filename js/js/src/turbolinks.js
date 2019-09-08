import TurboLinks from "turbolinks";
import axios from "axios";
TurboLinks.start();

document.addEventListener("turbolinks:load",function(){
    var postForms = document.querySelectorAll("form[method='post']");
    for(var element of postForms){
        element.addEventListener("submit",function(e){
            e.preventDefault();
            var formData = new FormData(element); 
            axios({
                url: element.action,
                method: "post",
                data: formData,
                config: {
                    headers:{
                        "Content-Type" : element.enctype
                    }
                }
            }).then(function(data){
                TurboLinks.visit(data.data);
            })
        })
    }
})