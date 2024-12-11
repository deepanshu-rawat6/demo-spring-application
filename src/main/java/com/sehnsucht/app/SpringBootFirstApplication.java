package com.sehnsucht.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;

@SpringBootApplication
public class SpringBootFirstApplication {
//    Spring IoC(Inversion of Control) -> focus on the Business Logic rather than on Object Creation

    public static void main(String[] args) {
//        Every time "Spring" creates an object -> present in the JVM container
//        So, in order to access to that container, we need to use Application Context

//        SpringApplication.run -> return ConfigurableApplicationContext(Interface)
//        ConfigurableApplicationContext -> extends ApplicationContext
//        And, then we need to mention @Component on top of the class, whose object we need to be taken care of by Spring.
        ApplicationContext context = SpringApplication.run(SpringBootFirstApplication.class, args);

//        Now via this context, we can call in our object without needing to create them
//        In Spring terminology, object is referred as "Bean"
//        hence we use getBean() method to load in our object when spring project is started
//        Alien obj = context.getBean(Alien.class);
//        obj.code();
//        System.out.println(obj.hashCode());
//
//        Alien obj1 = context.getBean(Alien.class);
//        obj1.code();
//        System.out.println(obj1.hashCode());

//        The object is created once using the Application Context, and the next time we try to create a new object of
//        our same component class "Alien", the same object is used.

//        Autowiring concept in Spring
//        In order to use nested classes, SpringBootFirstApplication -> Alien -> Laptop
//        Check more in the Alien.java file
        Alien obj = context.getBean(Alien.class);
        obj.code();

    }
}