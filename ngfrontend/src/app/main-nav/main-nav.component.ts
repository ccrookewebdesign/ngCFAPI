import { Component } from '@angular/core';
import { Router } from '@angular/router';
import {
  BreakpointObserver,
  Breakpoints,
  BreakpointState
} from '@angular/cdk/layout';
import { Observable } from 'rxjs';

import { UserService } from '../services/user.service';

@Component({
  selector: 'main-nav',
  templateUrl: './main-nav.component.html',
  styleUrls: ['./main-nav.component.css']
})
export class MainNavComponent {
  isHandset: Observable<BreakpointState> = this.breakpointObserver.observe(
    Breakpoints.Handset
  );

  constructor(
    private breakpointObserver: BreakpointObserver,
    private userService: UserService,
    private router: Router
  ) {}

  ngOnInit() {
    /* this.userService.loggedIn().subscribe(loggedIn => {
      console.log(loggedIn);
      this.isLoggedIn = loggedIn;
    }); */
  }

  isLoggedIn(): boolean {
    return this.userService.loggedIn();
  }

  logout() {
    this.userService.logout();
    this.router.navigate(['/login']);
  }
}
