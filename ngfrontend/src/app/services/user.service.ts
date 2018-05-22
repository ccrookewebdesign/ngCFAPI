import { APIResponse } from './user.service';
import { Injectable } from '@angular/core';
import { Http, Response, Headers, RequestOptions } from '@angular/http';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { map, tap, catchError } from 'rxjs/operators';

import { environment } from '../../environments/environment';

export interface User {
  userid: number;
  username: string;
  firstname: string;
  lastname: string;
  email: string;
  password: string;
  lastlogin?: string;
}

export interface APIResponse {
  success: string;
  message: string | User;
  errcode?: string;
  token?: string;
  data?: Object;
}

@Injectable()
export class UserService {
  public jwtToken: string;
  public currentUser: User = {
    userid: 0,
    username: '',
    firstname: '',
    lastname: '',
    email: '',
    password: '',
    lastlogin: ''
  };

  constructor(private http: HttpClient) {
    const theUser: any = JSON.parse(localStorage.getItem('currentUser'));

    if (theUser) {
      this.jwtToken = theUser.token;
    }
  }

  login(oUser): Observable<any> {
    const httpOptions = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json' })
    };

    return this.http
      .post(environment.apiUrl + 'login', oUser, httpOptions)
      .pipe(
        tap((response: APIResponse) => {
          if (response.success) {
            this.currentUser = <User>response.data;
            const userObj: any = {};
            userObj.user = response.data;
            userObj.token = response.token;
            this.jwtToken = response.token;

            localStorage.setItem('currentUser', JSON.stringify(userObj));
          }
        }),
        catchError(this.handleError)
      );
  }

  getUser(userid): Observable<any> {
    const httpOptions = {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        Authorization: `${this.jwtToken}`
      })
    };
    return this.http
      .get(`${environment.apiUrl}user/${userid}`, httpOptions)
      .pipe(catchError(this.handleError));
  }

  getUsers(): Observable<any> {
    const httpOptions = {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        Authorization: `${this.jwtToken}`
      })
    };
    return this.http
      .get(`${environment.apiUrl}users/`, httpOptions)
      .pipe(catchError(this.handleError));
  }

  insertUser(oUser): Observable<any> {
    const httpOptions = {
      headers: new HttpHeaders({ 'Content-Type': 'application/json' })
    };

    return this.http
      .post(environment.apiUrl + 'insertuser', oUser, httpOptions)
      .pipe(
        tap((response: APIResponse) => {
          if (response.success) {
            this.currentUser = <User>response.data;
            const userObj: any = {};
            userObj.user = response.message;
            userObj.token = response.token;
            this.jwtToken = response.token;
            localStorage.setItem('currentUser', JSON.stringify(userObj));
          }
        }),
        catchError(this.handleError)
      );
  }

  updateUser(userid, oUser): Observable<any> {
    const httpOptions = {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        Authorization: `${this.jwtToken}`
      })
    };

    return this.http
      .put(`${environment.apiUrl}user/${userid}`, oUser, httpOptions)
      .pipe(catchError(this.handleError));
  }

  deleteUser(userid): Observable<any> {
    const httpOptions = {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        Authorization: `${this.jwtToken}`
      })
    };

    return this.http
      .delete(`${environment.apiUrl}delete/${userid}`, httpOptions)
      .pipe(catchError(this.handleError));
  }

  logout(): void {
    this.currentUser = {
      userid: 0,
      username: '',
      firstname: '',
      lastname: '',
      email: '',
      password: '',
      lastlogin: ''
    };

    localStorage.removeItem('currentUser');
  }

  loggedIn(): boolean {
    return !!this.currentUser.userid;
  }

  private handleError(error: Response) {
    console.error('error: ');
    console.error(error);
    return of(error || 'Server error');
  }
}
