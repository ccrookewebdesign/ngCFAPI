import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot } from '@angular/router';

import { Observable } from 'rxjs';
import { of } from 'rxjs';
import { tap, map, filter, take, switchMap } from 'rxjs/operators';

import { UserService } from './user.service';

@Injectable()
export class AuthGuard implements CanActivate {
  constructor(private userService: UserService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): boolean {
    return this.loggedIn();
  }

  loggedIn(): boolean {
    if (this.userService.currentUser.userid) {
      return true;
    } else {
      this.router.navigate(['login']);
      return false;
    }
  }
}
