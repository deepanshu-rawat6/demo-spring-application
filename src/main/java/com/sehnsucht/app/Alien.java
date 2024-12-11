package com.sehnsucht.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class Alien {
//  By using the @Autowired annotation, we are able to handle nested calling of object all managed by Spring.
    @Autowired
    Laptop laptop;

    public void code() {
        laptop.compile();
    }
}
